require 'daemons'
require 'delayed/command'
require 'yaml'

module Snorby
  
  class Worker < Struct.new(:action)

    @@pid_path = "#{RAILS_ROOT}/tmp/pids"
    @@pid_file = "#{RAILS_ROOT}/tmp/pids/delayed_job.pid"

    def perform
      
      case action.to_sym
      when :start
        start
      when :stop
        stop
      when :restart
        restart
      when :zap
        zap
      end
      
    end

    def self.info
      return `ps aux |grep delayed_job |grep -v grep`.chomp.strip if running?
    end

    def self.pid
      File.open(@@pid_file).read.to_i if running?
    end

    def self.running?
      return true if File.exists?(@@pid_file)
      false
    end

    private

    def start(options={})
      `#{RAILS_ROOT}/script/delayed_job start --pid-dir #{@@pid_path} RAILS_ENV=#{Rails.env}`
    end
    
    def stop(options={})
      `#{RAILS_ROOT}/script/delayed_job stop --pid-dir #{@@pid_path} RAILS_ENV=#{Rails.env}`
    end

    def restart
      `#{RAILS_ROOT}/script/delayed_job restart --pid-dir #{@@pid_path} RAILS_ENV=#{Rails.env}`
    end
    
    def zap
      `#{RAILS_ROOT}/script/delayed_job zap --pid-dir #{@@pid_path} RAILS_ENV=#{Rails.env}`
    end

  end
  
end
