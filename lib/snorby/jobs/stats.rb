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
  module Jobs
    
    class Stats
      
      attr_accessor :events, :cache, :last_event
      
      def self.perform
        @events ||= since_last_cache
        return if @events.blank?
        @last_event ||= @events.last
        @cache = Cache.create(:sid => @last_event.sid, :cid => @last_event.cid, :ran_at => @last_event.timestamp) unless defined?(@cache)
      end
      
      private
      
      def self.since_last_cache
        return Event.all if Cache.all.blank?
        @cache = Cache.last
        Event.all(:timestamp.gt => @cache.ran_at)
      end
      
    end
    
  end
end