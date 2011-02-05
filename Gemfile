source 'http://rubygems.org'

RAILS_VERSION = '~> 3.0.3'
RSPEC_VERSION = '~> 2.0.0'

gem 'rails',                  RAILS_VERSION
gem 'jquery-rails'
gem 'bundler',                '~> 1.0.0'

gem 'activesupport',          RAILS_VERSION, :require => 'active_support'
gem 'actionpack',             RAILS_VERSION, :require => 'action_pack'
gem 'actionmailer',           RAILS_VERSION, :require => 'action_mailer'
gem 'railties',               RAILS_VERSION, :require => 'rails'

gem 'mysql2'
gem 'will_paginate',          '~> 3.0.pre2'
gem 'composite_primary_keys', '~> 3.1.1'

# Deploy with Capistrano
gem 'capistrano'

# Rails Plugins
gem 'jammit',                 '~> 0.5.4'
gem 'devise',                 '~> 1.1.3'
gem "mail",                   '~> 2.2.10'
gem "RedCloth",               "~> 4.0", :require => 'redcloth'
gem 'chronic',                '~> 0.3.0'
gem 'pdfkit',                 '~> 0.4.6'
gem 'ezprint',                :git => 'http://github.com/mephux/ezprint.git', :branch => 'rails3', :require => 'ezprint'
gem 'daemons',                '~> 1.1.0'
gem 'delayed_job',            '~> 2.1.3'
gem 'rmagick',                '~> 2.13.1'
gem 'paperclip',              '~> 2.3.8'
gem 'net-dns',                '~> 0.6.1'
gem 'whois',                  '~> 1.6.6'
gem 'simple_form',            '~> 1.2.2'

group(:test) do
  gem 'capybara'

  gem 'rspec',                RSPEC_VERSION
  gem 'rspec-core',		        RSPEC_VERSION, :require => 'rspec/core'
  gem 'rspec-expectations',	  RSPEC_VERSION, :require => 'rspec/expectations'
  gem 'rspec-rails',		      RSPEC_VERSION
end




