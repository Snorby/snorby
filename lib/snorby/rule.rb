require "pathname"

# Snorby
module Snorby
  # Rule
  module Rule
   
    def self.paths=(path)
      @path ||= path
    end

    def self.paths
      @path
    end

    def self.get(options={})
      return false unless @path
      @rule = Snorby::Rule::Search.new(options)
      @rule ? @rule : false
    end


    class Search

      attr_accessor :rule, :revision_id, :generator_id, :rule_id

      def initialize(options)
        @rule_id = options.fetch(:rule_id, 0).to_i
        @generator_id = options.fetch(:generator_id, 0).to_i
        @revision_id = options.fetch(:revision_id, 0).to_i
        @rule = false
       
        @generator_id = nil if @generator_id.zero? || @generator_id == 1 
        @revision_id = nil if @revision_id.zero?
        
        search_for_rule
      end

      def search_for_rule
        if Snorby::Rule.paths.is_a?(Array)

          Snorby::Rule.paths.each do |path|
            return @rule if @rule
            pathname = Pathname.new(path)
            search(pathname)
          end
        else
          
          search(Snorby::Rule.paths)
        end

        @rule
      end

      def to_s
        @rule
      end

      def found?
        return true if @rule
        false
      end

      def search(path)
        Dir.glob(path + '*').each do |file|
          return @rule if @rule
          path = Pathname.new(file)
         
          if File.extname(path) == ".rules"
            file = File.open(path)
            
            file.each_line do |line|
              return @rule if @rule

              next if line.match(/^\#/)
              next unless line.match(/sid\:#{@rule_id}\;/)
              

              if @revision_id
                next unless line.match(/rev\:#{@revision_id}\;/)
              end
              
              if @generator_id
                next unless line.match(/gid\:#{@generator_id}\;/)
              end

              @rule = line
            end

          end

        end

      end # Method Search

    end # Search End

  end # Rule End

end # Snorby End
