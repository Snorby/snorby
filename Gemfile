source 'http://rubygems.org'

RAILS_VERSION = '3.1.0'
RSPEC_VERSION = '~> 2.0.0'
DATAMAPPER = 'http://github.com/datamapper'
DM_VERSION = '~> 1.2.0'

gem 'rake', '0.9.2'
gem 'thin'

gem 'rails',                       RAILS_VERSION
gem 'jquery-rails'
gem 'bundler',                     '>= 1.0.0'
gem 'env'

# Jruby
gem 'jruby-openssl',   :platforms => :jruby
gem 'warbler', :platforms => :jruby
gem 'jruby-rack-worker', :platforms => :jruby
# gem 'glassfish', :platforms => :jruby

# DateTime Patches
gem 'home_run',                    :require => 'date', :platforms => :mri

gem 'activesupport',               RAILS_VERSION, :require => 'active_support'
gem 'actionpack',                  RAILS_VERSION, :require => 'action_pack'
gem 'actionmailer',                RAILS_VERSION, :require => 'action_mailer'
gem 'railties',                    RAILS_VERSION, :require => 'rails'
gem 'dm-core',                     DM_VERSION
gem 'dm-rails',                    DM_VERSION
gem 'dm-do-adapter',               DM_VERSION
gem 'dm-active_model',             DM_VERSION
gem 'dm-mysql-adapter',            DM_VERSION

gem 'dm-pager',                    '~> 1.1.0'
gem "dm-ar-finders",               DM_VERSION
gem 'dm-migrations',               DM_VERSION
gem 'dm-types',                    DM_VERSION
gem 'dm-validations',              DM_VERSION
gem 'dm-constraints',              DM_VERSION
gem 'dm-transactions',             DM_VERSION
gem 'dm-aggregates',               DM_VERSION
gem 'dm-timestamps',               DM_VERSION
gem 'dm-observer',                 DM_VERSION
gem 'dm-serializer',               DM_VERSION
gem 'dm-chunked_query',            '~> 0.3'

# Deploy with Capistrano
gem 'capistrano'

# Rails Plugins
gem 'jammit',                      '~> 0.5.4'
gem 'devise',                      '~> 1.4'
gem 'dm-devise',                   '~> 1.5'
gem 'rubycas-client'
gem 'devise_cas_authenticatable',  :git => 'http://github.com/Snorby/snorby_cas_authenticatable.git'
gem "mail",                        '~> 2.3'
gem "RedCloth",                    "~> 4.2.9", :require => 'redcloth'
gem 'chronic',                     '~> 0.3.0'
gem 'pdfkit',                      '~> 0.4.6'
gem 'ezprint',                     :git => 'http://github.com/mephux/ezprint.git', :branch => 'rails3', :require => 'ezprint'
gem 'daemons',                     '~> 1.1.0'

gem 'delayed_job',                 '~> 2.1.4'
gem 'delayed_job_data_mapper',     '~> 1.0.0.rc', :git => 'http://github.com/Snorby/delayed_job_data_mapper.git'

# Working On This
# gem 'delayed_job',                 '~> 3.0'
# gem 'delayed_job_data_mapper',     '~> 1.0.0.rc', :git => 'https://github.com/collectiveidea/delayed_job_data_mapper.git'

# Old - Remove Avatar Support
# gem 'rmagick',                     '~> 2.13.1'
# gem 'dm-paperclip',                '~> 2.4.1', :git => 'http://github.com/Snorby/dm-paperclip.git'

gem 'net-dns',                     '~> 0.6.1'
gem 'whois',                       '~> 2.3.0'
gem 'simple_form',                 '~> 1.2.2'
gem 'geoip',                       '~> 1.1.1'
gem 'netaddr',                     '~> 1.5.0'


group(:development) do
	gem "letter_opener"
end

group(:test) do
  gem 'capybara'

  gem 'rspec',                RSPEC_VERSION
  gem 'rspec-core',		        RSPEC_VERSION, :require => 'rspec/core'
  gem 'rspec-expectations',	  RSPEC_VERSION, :require => 'rspec/expectations'
  gem 'rspec-rails',		      RSPEC_VERSION
  gem 'ansi'
  gem 'turn'
  gem 'minitest'
end

group(:doc) do
  gem 'dm-visualizer',	'~> 0.1.0'
end
