module Synthesis
  class AssetPackage

    @asset_base_path    = "#{Rails.root}/public"
    @asset_packages_yml = File.exists?("#{Rails.root}/config/asset_packages.yml") ? YAML.load_file("#{Rails.root}/config/asset_packages.yml") : nil

    # singleton methods
    class << self
      attr_accessor :asset_base_path,
                    :asset_packages_yml

      attr_writer   :merge_environments

      def merge_environments
        @merge_environments ||= ["production"]
      end

      def parse_path(path)
        /^(?:(.*)\/)?([^\/]+)$/.match(path).to_a
      end

      def find_by_type(asset_type)
        asset_packages_yml[asset_type].map { |p| self.new(asset_type, p) }
      end

      def find_by_target(asset_type, target)
        package_hash = asset_packages_yml[asset_type].find {|p| p.keys.first == target }
        package_hash ? self.new(asset_type, package_hash) : nil
      end

      def find_by_source(asset_type, source)
        path_parts = parse_path(source)
        package_hash = asset_packages_yml[asset_type].find do |p|
          key = p.keys.first
          p[key].include?(path_parts[2]) && (parse_path(key)[1] == path_parts[1])
        end
        package_hash ? self.new(asset_type, package_hash) : nil
      end

      def targets_from_sources(asset_type, sources)
        package_names = Array.new
        sources.each do |source|
          package = find_by_target(asset_type, source) || find_by_source(asset_type, source)
          package_names << (package ? package.current_file : source)
        end
        package_names.uniq
      end

      def sources_from_targets(asset_type, targets)
        source_names = Array.new
        targets.each do |target|
          package = find_by_target(asset_type, target)
          source_names += (package ? package.sources.collect do |src|
            package.target_dir.gsub(/^(.+)$/, '\1/') + src
          end : target.to_a)
        end
        source_names.uniq
      end

      def build_all
        asset_packages_yml.keys.each do |asset_type|
          asset_packages_yml[asset_type].each { |p| self.new(asset_type, p).build }
        end
      end

      def delete_all
        asset_packages_yml.keys.each do |asset_type|
          asset_packages_yml[asset_type].each { |p| self.new(asset_type, p).delete_previous_build }
        end
      end

      def create_yml
        unless File.exists?("#{Rails.root}/config/asset_packages.yml")
          asset_yml = Hash.new

          asset_yml['javascripts'] = [{"base" => build_file_list("#{Rails.root}/public/javascripts", "js")}]
          asset_yml['stylesheets'] = [{"base" => build_file_list("#{Rails.root}/public/stylesheets", "css")}]

          File.open("#{Rails.root}/config/asset_packages.yml", "w") do |out|
            YAML.dump(asset_yml, out)
          end

          log "config/asset_packages.yml example file created!"
          log "Please reorder files under 'base' so dependencies are loaded in correct order."
        else
          log "config/asset_packages.yml already exists. Aborting task..."
        end
      end

    end

    # instance methods
    attr_accessor :asset_type, :target, :target_dir, :sources

    def initialize(asset_type, package_hash)
      target_parts = self.class.parse_path(package_hash.keys.first)
      @target_dir = target_parts[1].to_s
      @target = target_parts[2].to_s
      @sources = package_hash[package_hash.keys.first]
      @asset_type = asset_type
      @asset_path = "#{self.class.asset_base_path}/#{@asset_type}#{@target_dir.gsub(/^(.+)$/, '/\1')}"
      @extension = get_extension
      @file_name = "#{@target}_packaged.#{@extension}"
      @full_path = File.join(@asset_path, @file_name)
      @latest_mtime = get_latest_mtime
    end

    def package_exists?
      File.exists?(@full_path)
    end

    def current_file
      build unless package_exists?

      path = @target_dir.gsub(/^(.+)$/, '\1/')
      "#{path}#{@target}_packaged"
    end

    def build
      delete_previous_build
      create_new_build
    end

    def delete_previous_build
      File.delete(@full_path) if File.exists?(@full_path)
    end

    private
      def create_new_build
        new_build_path = "#{@asset_path}/#{@target}_packaged.#{@extension}"
        if File.exists?(new_build_path)
          log "Latest version already exists: #{new_build_path}"
        else
          File.open(new_build_path, "w") {|f| f.write(compressed_file) }
          File.utime(0, @latest_mtime, new_build_path)
          log "Created #{new_build_path}"
        end
      end

      def merged_file
        merged_file = ""
        @sources.each {|s|
          File.open("#{@asset_path}/#{s}.#{@extension}", "r") { |f|
            merged_file += f.read + "\n"
          }
        }
        merged_file
      end

      # Store the latest mtime so that we can attach it to the merged archive.
      # This allows the Rails asset IDs to work as intended for caching purposes -
      # if none of the files in the archive have been modified since the last build,
      # then the new build (typically done at deploy time) will keep the same mtime
      # (and Rails asset ID).
      #
      def get_latest_mtime
        return @sources.collect{ |s| File.mtime("#{@asset_path}/#{s}.#{@extension}") }.max
      end

      def compressed_file
        case @asset_type
          when "javascripts" then compress_js(merged_file)
          when "stylesheets" then compress_css(merged_file)
        end
      end

      def compress_js(source, minifier = 'jsmin')
        case minifier
          when 'google_closure' then result = compress_google_closure(source)
        else result = compress_js_min(source)
        end
        result
      end

      def compress_js_min(source)
        require 'jsmin'
        JSMin.compress(source)
      end

      def compress_google_closure(source)
        require 'net/http'
        require 'uri'

        url = URI.parse('http://closure-compiler.appspot.com/compile')
        req = Net::HTTP::Post.new(url.path)
        req.set_form_data(
        {
          'js_code'=> source,
          'compilation_level' => 'SIMPLE_OPTIMIZATIONS',
          'output_format' => 'text',
          'output_info' => 'compiled_code'
        })
        res = Net::HTTP.new(url.host, url.port).start {|http| http.request(req) }
        case res
        when Net::HTTPSuccess, Net::HTTPRedirection
          result = res.body
        else
          log("Error compiling js with Google's Closure Compiler. Falling back on js_min...")
          result = compress_js_jsmin(source)
        end
        result
      end

      def compress_css(source)
        source.gsub!(/\s+/, " ")           # collapse space
        source.gsub!(/\/\*(.*?)\*\//, "")  # remove comments - caution, might want to remove this if using css hacks
        source.gsub!(/\} /, "}\n")         # add line breaks
        source.gsub!(/\n$/, "")            # remove last break
        source.gsub!(/ \{ /, " {")         # trim inside brackets
        source.gsub!(/; \}/, "}")          # trim inside brackets
        
        # add timestamps to images in css
        source.gsub!(/url\(['"]?([^'"\)]+?(?:gif|png|jpe?g))['"]?\)/i) do |match|
        
          file = $1
          path = File.join(Rails.root, 'public')
          
          if file.starts_with?('/')
            path = File.join(path, file) 
          else
            path = File.join(path, 'stylesheets', file)
          end
          
          
          match.gsub(file, "#{file}?#{File.new(path).mtime.to_i}")
        end
        
        source
      end

      def get_extension
        case @asset_type
          when "javascripts" then "js"
          when "stylesheets" then "css"
        end
      end

      def log(message)
        self.class.log(message)
      end

      def self.log(message)
        puts message
      end

      def self.build_file_list(path, extension)
        re = Regexp.new(".#{extension}\\z")
        file_list = Dir.new(path).entries.delete_if { |x| ! (x =~ re) }.map {|x| x.chomp(".#{extension}")}
        # reverse javascript entries so prototype comes first on a base rails app
        file_list.reverse! if extension == "js"
        file_list
      end

  end
end
