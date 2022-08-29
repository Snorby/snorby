source 'https://rubygems.org'

RAILS_VERSION = '3.2.22'
RSPEC_VERSION = '~> 3.8.0'
DATAMAPPER    = 'https://github.com/datamapper'
DM_VERSION    = '~> 1.2.0'

gem 'rake'
gem 'request_store'
gem 'rails',                       RAILS_VERSION
gem 'jquery-rails'
gem 'bundler'
gem 'env'
gem 'json'

# Jruby
gem 'jruby-openssl',               :platforms => :jruby
gem 'warbler',                     :platforms => :jruby
gem 'jruby-rack-worker',           :platforms => :jruby
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
gem 'dm-postgres-adapter',         DM_VERSION

gem 'dm-pager'
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
gem 'dm-is-read_only',             '~> 0.3'
gem 'dm-chunked_query',            '~> 0.3'

# Deploy with Capistrano
gem 'capistrano'

# Rails Plugins
gem 'jammit',                      '~> 0.5.4'
gem 'cancan',                      '~> 1.6'
gem 'devise',                      '~> 1.4'
gem 'dm-devise',                   '~> 1.5'
gem 'rubycas-client'
gem 'devise_cas_authenticatable'
gem 'mail'
gem 'RedCloth',                    '~> 4.2.9', :require => 'redcloth'
gem 'chronic'
gem 'pdfkit'
gem 'ezprint'
gem 'daemons'                     

gem 'delayed_job'
gem 'delayed_job_data_mapper'

#do_mysq ? orso _
gem 'do_mysql'
# Working On This
# gem 'delayed_job',                 '~> 3.0'
# gem 'delayed_job_data_mapper',     '~> 1.0.0.rc', :git => 'https://github.com/collectiveidea/delayed_job_data_mapper.git'

# Old - Remove Avatar Support
# gem 'rmagick',                     '~> 2.13.1'
# gem 'dm-paperclip',                '~> 2.4.1', :git => 'https://github.com/Snorby/dm-paperclip.git'

gem 'net-dns'
gem 'whois'
gem 'whois-parser'
gem 'simple_form'
gem 'geoip'
gem 'netaddr'
gem 'dm-zone-types'
gem 'timezone_local'

group(:development) do
  gem "letter_opener"
  gem 'thin'
  gem 'byebug'
end

group(:test) do
  gem 'capybara'
  gem 'test-unit'	
  gem 'rspec',                	  RSPEC_VERSION
  gem 'rspec-core',               RSPEC_VERSION, :require => 'rspec/core'
  gem 'rspec-expectations',       RSPEC_VERSION, :require => 'rspec/expectations'
  gem 'rspec-rails',		          RSPEC_VERSION
  gem 'ansi'
  gem 'turn'
  gem 'minitest'
end

group(:doc) do
  gem 'dm-visualizer',	'~> 0.1.0'
end
