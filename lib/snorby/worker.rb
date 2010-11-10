# Snorby - A Web interface for Snort.
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
      return `ps aux #{Worker.pid} |grep delayed_job |grep -v grep`.chomp.strip if running?
    end

    def self.pid
      File.open(@@pid_file).read.to_i if running?
    end

    def self.running?
      return true if File.exists?(@@pid_file)
      false
    end

    private

    def start
      `#{Rails.root}/script/delayed_job start --pid-dir #{@@pid_path} RAILS_ENV=#{Rails.env}`
      # Snorby::Jobs::SensorCache.new(false).perform unless Snorby::Jobs.sensor_cache?
    end
    
    def stop(options={})
      `#{Rails.root}/script/delayed_job stop --pid-dir #{@@pid_path} RAILS_ENV=#{Rails.env}`
    end

    def restart
      `#{Rails.root}/script/delayed_job restart --pid-dir #{@@pid_path} RAILS_ENV=#{Rails.env}`
    end
    
    def zap
      `#{Rails.root}/script/delayed_job zap --pid-dir #{@@pid_path} RAILS_ENV=#{Rails.env}`
    end

  end
  
end
