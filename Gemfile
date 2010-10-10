source 'http://rubygems.org'

gem 'rails', '3.0.0'
gem 'jquery-rails'

RAILS_VERSION = '~> 3.0.0'
DM_VERSION = '~> 1.0.2'

gem 'activesupport',          RAILS_VERSION, :require => 'active_support'
gem 'actionpack',             RAILS_VERSION, :require => 'action_pack'
gem 'actionmailer',           RAILS_VERSION, :require => 'action_mailer'
gem 'railties',               RAILS_VERSION, :require => 'rails'

gem 'mysql',                  '2.8.1'
gem 'dm-rails',               '~> 1.0.3'

gem 'dm-mysql-adapter',       DM_VERSION
# gem 'dm-sqlite-adapter',    DM_VERSION
# gem 'dm-postgres-adapter',  DM_VERSION
# gem 'dm-oracle-adapter',    DM_VERSION
# gem 'dm-sqlserver-adapter', DM_VERSION

gem 'dm-migrations',          DM_VERSION
gem 'dm-types',               DM_VERSION
gem 'dm-validations',         DM_VERSION
gem 'dm-constraints',         DM_VERSION
gem 'dm-transactions',        DM_VERSION
gem 'dm-aggregates',          DM_VERSION
gem 'dm-timestamps',          DM_VERSION
gem 'dm-observer',            DM_VERSION
gem 'dm-devise',              '~> 1.1.0'
gem 'dm-serializer',          '~> 1.0.2'

# Deploy with Capistrano
gem 'capistrano'

# Rails Plugins
gem 'devise',                 '~> 1.1.3'
gem 'will_paginate', '~> 3.0', :git => 'git://github.com/mislav/will_paginate.git', :branch => 'rails3'

group(:development, :test) do
  gem 'nifty-generators',     '~> 0.4.1' 
end
