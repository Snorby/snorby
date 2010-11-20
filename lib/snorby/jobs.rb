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

require 'snorby/jobs/cache_helper'
require 'snorby/jobs/daily_cache_job'
require 'snorby/jobs/sensor_cache_job'

module Snorby

  module Jobs

    def self.find
      Delayed::Backend::DataMapper::Job
    end

    def self.run(obj, priority=1, time=Time.now)
      Delayed::Job.enqueue(obj, priority, time)
    end

    def self.start
      Jobs::SensorCacheJob.new(false).perform unless Jobs.sensor_cache?
      Jobs::DailyCacheJob.new(false).perform unless Jobs.daily_cache?
    end

    def self.sensor_cache
      Snorby::Jobs.find.first(:handler.like => "%!ruby/struct:Snorby::Jobs::SensorCacheJob%")
    end

    def self.daily_cache
      Snorby::Jobs.find.first(:handler.like => "%!ruby/struct:Snorby::Jobs::DailyCacheJob%")
    end

    def self.sensor_cache?
      !Snorby::Jobs.find.first(:handler.like => "%!ruby/struct:Snorby::Jobs::SensorCacheJob%").blank?
    end

    def self.daily_cache?
      !Snorby::Jobs.find.first(:handler.like => "%!ruby/struct:Snorby::Jobs::DailyCacheJob%").blank?
    end

    def self.sensor_caching?
      return true if Jobs.sensor_cache? && Jobs.sensor_cache.locked_at
      false
    end

    def self.daily_caching?
      return true if Jobs.daily_cache? && Jobs.daily_cache.locked_at
      false
    end

    def self.caching?
      return true if (Jobs.sensor_caching? || Jobs.daily_caching?)
      false
    end

    def self.run_now!
      Jobs.sensor_cache.update(:run_at => Time.now + 10.second) if Jobs.sensor_cache?
      Jobs.daily_cache.update(:run_at => Time.now + 10.second) if Jobs.daily_cache?
    end

    def self.clear_cache(are_you_sure=false)
      if are_you_sure
        Cache.all.destroy!
        DailyCache.all.destroy!
      end
    end

  end
end
