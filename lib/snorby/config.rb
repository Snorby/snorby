require 'env'
require 'fileutils'

module Snorby

  class Config

    attr_accessor :config_path, :path, :template_path

    def initialize
      @path = File.join(File.expand_path('../../../', __FILE__), 'config')
      @config_path = File.join(@path, 'snorby.yml')
      @template_path = File.join(File.expand_path('../../../', __FILE__), 'config', 'snorby-config-template.yml')
      @config = nil
    end

    def build
      FileUtils.mkdir_p(@path)
      unless File.exists?(@config_path)
        build_default_config
      end

      validate!
    end

    def configuration
      @configuration ||= @config
    end

    def current_configuration
      # Snorby Environment Specific Configurations
      configuration[Rails.env].symbolize_keys
    end

    private

    def build_default_config
      FileUtils.cp_r(@template_path, @config_path)
    end

    def validate!
      @config = YAML.load_file(@config_path)
      unless @config['configured_properly']
        STDERR.puts "Snorby Configuration Error"
        STDERR.puts "* Please EDIT #{@config_path}"
        exit 1
      end
    end

  end

end
