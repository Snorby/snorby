require File.expand_path('../boot', __FILE__)

# require 'rails/all'
require 'action_controller/railtie'
require 'dm-rails/railtie'
require 'action_mailer/railtie'
require 'rails/test_unit/railtie'
require 'timezone_local'

# If you have a Gemfile, require the gems listed there, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env) if defined?(Bundler)

module Snorby

  config_dir = File.expand_path('../', __FILE__)
  # Check Ruby Version
  unless RUBY_VERSION.starts_with?("2.") || RUBY_VERSION.starts_with?("1.9")
    puts "Snorby requires Ruby version 1.9.x"
    puts "We suggest using Ruby Version Manager (RVM) https://rvm.io/ to install the newest release"
    exit 1
  end

  # Check For snorby_config.yml
  unless File.exists?(config_dir + "/snorby_config.yml")
    puts "Snorby Configuration Error"
    puts "* Please EDIT and rename config/snorby_config.yml.example to config/snorby_config.yml"
    exit 1
  end
  
  # Check For database.yml
  unless File.exists?(config_dir + "/database.yml")
    puts "Snorby Configuration Error"
    puts "* Please EDIT and rename config/database.yml.example to config/database.yml"
    exit 1
  end

  # Snorby Environment Specific Configurations
  raw_config = File.read(config_dir + "/snorby_config.yml")
  CONFIG = YAML.load(raw_config)[Rails.env].symbolize_keys

  # Default authentication to database
  unless CONFIG.has_key?(:authentication_mode)
    CONFIG[:authentication_mode] = "database"
  end

  # default base uri is none...
  unless CONFIG.has_key?(:baseuri)
    CONFIG[:baseuri] = ""
  end

  class Application < Rails::Application

    config.threadsafe!
    config.dependency_loading = true
    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += %W(#{config.root}/lib)

    PDFKit.configure do |config|
      config.wkhtmltopdf = Snorby::CONFIG[:wkhtmltopdf]
      config.default_options = {
          :page_size => 'Legal',
          :print_media_type => true
        }
    end

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'
    #

    time_zone = CONFIG[:time_zone] # set your local time zone here. use rake time:zones:local to choose a value, or use UTC.

    unless time_zone
      # try to detect zone using
      detected_time_zone = TimeZone::Local.get
   
      if detected_time_zone
        time_zone = detected_time_zone.name
        puts "No time_zone specified in snorby_config.yml; detected time_zone: #{time_zone}"
      else
        puts "*** Warning:  no time zone is set in config/application.rb. Using UTC as the default time and behavior may be unexpected."
        puts "*** You can manually set the timezone in config/snorby_config.yml in the time_zone setting."
        puts "*** Valid time zones can be found by running `rake time:zones:local`"
        time_zone = "UTC"
      end
    end

    config.time_zone = time_zone

    DataMapper::Zone::Types.storage_zone = time_zone
    CONFIG[:time_zone] = time_zone unless CONFIG[:time_zone]

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # JavaScript files you want as :defaults (application.js is always included).
    # config.action_view.javascript_expansions[:defaults] = %w(jquery rails)
    
    config.generators do |g|
      g.orm             :data_mapper
      g.template_engine :erb
      g.test_framework  :rspec
    end
    
    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Enable SSL if it was enabled in the configuration
    if CONFIG.has_key?(:ssl) && CONFIG[:ssl]
      config.force_ssl = true
      config.action_mailer.default_url_options = { :protocol => 'https', :host => Snorby::CONFIG[:domain] }
    else
      config.action_mailer.default_url_options = { :host => Snorby::CONFIG[:domain] }
    end
  end

end
