source 'http://rubygems.org'

gem 'rails', '3.0.1'
gem 'jquery-rails'

RAILS_VERSION = '~> 3.0.1'
RSPEC_VERSION = '~> 2.0.0'
DM_VERSION = '~> 1.0.2'

gem 'bundler',	'~> 1.0.0'

gem 'activesupport',          RAILS_VERSION, :require => 'active_support'
gem 'actionpack',             RAILS_VERSION, :require => 'action_pack'
gem 'actionmailer',           RAILS_VERSION, :require => 'action_mailer'
gem 'railties',               RAILS_VERSION, :require => 'rails'

gem 'dm-rails',               '~> 1.0.3'
gem 'dm-do-adapter',          DM_VERSION
gem 'dm-active_model',        DM_VERSION

gem 'dm-mysql-adapter',       DM_VERSION
# gem 'dm-sqlite-adapter',    DM_VERSION

gem 'dm-pager'
gem 'dm-migrations',          DM_VERSION
gem 'dm-types',               DM_VERSION
gem 'dm-validations',         DM_VERSION
gem 'dm-constraints',         DM_VERSION
gem 'dm-transactions',        DM_VERSION
gem 'dm-aggregates',          DM_VERSION
gem 'dm-timestamps',          DM_VERSION
gem 'dm-observer',            DM_VERSION
gem 'dm-devise',              '~> 1.1.0'
gem 'dm-serializer',          DM_VERSION

# Deploy with Capistrano
gem 'capistrano'

# Rails Plugins
gem 'pdfkit',                 '~> 0.4.6'
gem 'daemons',                '~> 1.1.0'
gem 'delayed_job',            '~> 2.1.0.pre2'
gem 'delayed_job_data_mapper','~> 1.0.0.rc'
# #gem 'dm-is-counter_cacheable','~> 0.1.0'
gem 'dm-paperclip',           '~> 2.3', :git => 'http://github.com/postmodern/dm-paperclip.git', :branch => 'postmodern'
gem 'net-dns',                '~> 0.6.1'
gem 'whois',                  '~> 1.3.9'
gem 'simple_form',            '~> 1.2.2'
gem 'devise',                 '~> 1.1.3'

group(:test) do
  gem 'capybara'

  gem 'rspec',			RSPEC_VERSION
  gem 'rspec-core',		RSPEC_VERSION, :require => 'rspec/core'
  gem 'rspec-expectations',	RSPEC_VERSION, :require => 'rspec/expectations'
  gem 'rspec-rails',		RSPEC_VERSION
end

group(:doc) do
  gem 'dm-visualizer',	'~> 0.1.0'
end