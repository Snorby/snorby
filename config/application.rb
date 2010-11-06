require File.expand_path('../boot', __FILE__)

# require 'rails/all'
require 'action_controller/railtie'
require 'dm-rails/railtie'
require 'action_mailer/railtie'

# If you have a Gemfile, require the gems listed there, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env) if defined?(Bundler)

module Snorby
  
  # Snorby Environment Specific Configurations
  raw_config = File.read("config/snorby_config.yml")
  CONFIG = YAML.load(raw_config)[Rails.env].symbolize_keys
  
  # Snorby Version
  VERSION = '2.0.0'
  
  class Application < Rails::Application
    
    require 'pdfkit'
        
    PDFKit.configure do |config|
      config.wkhtmltopdf = '/Users/mephux/.rvm/gems/ruby-1.9.2-p0/bin/wkhtmltopdf'
      config.default_options = {
          :page_size => 'Legal',
          :print_media_type => true
        }
    end
    
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += %W(#{config.root}/lib)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # JavaScript files you want as :defaults (application.js is always included).
    # config.action_view.javascript_expansions[:defaults] = %w(jquery rails)

    # Configure the default encoding used in templates for Ruby 1.9.
    
    config.generators do |g|
      g.orm             :data_mapper
      g.template_engine :erb
      g.test_framework  :rspec
    end
    
    config.encoding = "utf-8"

    config.action_mailer.default_url_options = { :host => Snorby::CONFIG[:domain] }

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]
  end
end
