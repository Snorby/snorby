require 'rubygems'

`rm -rf test/fake_root`
`mkdir -p test/fake_root/tmp`

module Rails
  def self.root
    File.expand_path("test/fake_root")
  end

  def self.backtrace_cleaner
    ActiveSupport::BacktraceCleaner.new
  end

  def self.env=(x)
    @env = x
  end

  def self.env
    @env
  end
end

require 'rack'
require 'action_view'
require 'action_controller'
require 'rails/backtrace_cleaner'

$LOAD_PATH << 'lib'
require 'init'

require 'test/unit'
require 'action_controller/test_process'
require 'mocha'

ActionController::Base.logger = nil
ActionController::Routing::Routes.reload rescue nil