module Snorby
  
  class Worker < Struct.new(:action)

    @@pid_path = "#{Rails.root}/tmp/pids"
    
    @@pid_file = "#{Rails.root}/tmp/pids/delayed_job.pid"

    def perform
      
      case action.to_sym
      when :start
        Worker.start
      when :stop
        Worker.stop
      when :restart
        Worker.restart
      when :zap
        Worker.zap
      end
      
    end

    def self.problems?
      worker_and_caches = (!Snorby::Worker.running? || !Snorby::Jobs.sensor_cache?)
      Setting.geoip? ? ( worker_and_caches || !Snorby::Jobs.geoip_update?) : worker_and_caches
    end

    def self.process
      if Worker.pid
        if RUBY_PLATFORM =~ /solaris/ then
          Snorby::Process.new(`ps -o ruser,pid,pcpu,pmem,vsz,rss,tty,s,stime,etime,args -p #{Worker.pid} |grep delayed_job |grep -v grep`.chomp.strip)
        else
          if RUBY_PLATFORM =~ /freebsd/ then
            Snorby::Process.new(`ps -w -w -o ruser,pid,pcpu,pmem,vsz,rss,tty,s,stime,etime,args -p #{Worker.pid} |grep delayed_job |grep -v grep`.chomp.strip)
          else
            Snorby::Process.new(`ps -o ruser,pid,%cpu,%mem,vsize,rss,tt,stat,start,etime,command -p #{Worker.pid} |grep delayed_job |grep -v grep`.chomp.strip)
          end
        end
      end
    end

    def self.pid
      File.open(@@pid_file).read.to_i if File.exists?(@@pid_file)
    end

    def self.running?
      return true if File.exists?(@@pid_file) && !Worker.process.raw.empty?
      false
    end
    
    def self.start
      `#{Rails.root}/script/delayed_job start --pid-dir #{@@pid_path} RAILS_ENV=#{Rails.env}`
    end
    
    def self.stop
      `#{Rails.root}/script/delayed_job stop --pid-dir #{@@pid_path} RAILS_ENV=#{Rails.env}`
    end

    def self.restart
      `#{Rails.root}/script/delayed_job restart --pid-dir #{@@pid_path} RAILS_ENV=#{Rails.env}`
    end
    
    def self.zap
      `#{Rails.root}/script/delayed_job zap --pid-dir #{@@pid_path} RAILS_ENV=#{Rails.env}`
    end

  end
  
end
