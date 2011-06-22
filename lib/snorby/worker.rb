# Snorby - All About Simplicity.
# 
# Copyright (c) 2010 Dustin Willis Webber (dustin.webber at gmail.com)
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

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
      return true if (!Snorby::Worker.running? || !Snorby::Jobs.sensor_cache? || !Snorby::Jobs.daily_cache?)
      false
    end

    def self.process
      return Snorby::Process.new(`ps aux -p #{Worker.pid} |grep delayed_job |grep -v grep`.chomp.strip)
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
      # Snorby::Jobs::SensorCacheJob.new(false).perform unless Snorby::Jobs.sensor_cache?
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
