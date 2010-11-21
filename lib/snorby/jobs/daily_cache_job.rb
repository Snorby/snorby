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
    class DailyCacheJob < Struct.new(:verbose)
      
      include Snorby::Jobs::CacheHelper
      
      class CacheCompleted < Exception; end;
      
      def perform
        @stop_date = Time.now.yesterday.end_of_day
        
        begin
          
          if DailyCache.all.blank?
            day_start = Event.first.timestamp.beginning_of_day
            day_end = Event.first.timestamp.end_of_day

            Sensor.all.each do |sensor|
              @sensor = sensor
              build_cache(day_start, day_end)
            end

          else
            
            Sensor.all.each do |sensor|
              @sensor = sensor
              
              if @sensor.daily_cache.blank?
                
                next unless @sensor.events.first
                
                day_start = @sensor.events.first.timestamp.beginning_of_day
                day_end = @sensor.events.first.timestamp.end_of_day
                
              else
                
                day_start = @sensor.daily_cache.last.ran_at.tomorrow.beginning_of_day
                day_end = @sensor.daily_cache.last.ran_at.tomorrow.end_of_day
                
              end
              
              build_cache(day_start, day_end)
            end
            
          end
          
          Snorby::Jobs.daily_cache.destroy! if Snorby::Jobs.daily_cache?
          Delayed::Job.enqueue(Snorby::Jobs::DailyCacheJob.new(false), 1, Time.now.tomorrow.beginning_of_day)
          
        rescue Interrupt
          @cache.destroy! if defined?(@cache)
        end

      end


      def build_cache(day_start, day_end)

        @events = Event.between(day_start, day_end).all(:sid => @sensor.sid)
        
        @tcp_events = []
        @udp_events = []
        @icmp_events = []
        
        
        if day_end >= @stop_date
          logit "No New Events To Cache..."
          return
        end
        
        unless @events.blank?
          
          logit "\nNew Day: #{day_start} - #{day_end}", false
          
          @cache = DailyCache.create(:ran_at => day_start, :sensor => @sensor)
          create_cache_record

          new_time = @events.last.timestamp.end_of_day + 1.day
          new_start_day = new_time.beginning_of_day
          new_end_day = new_time.end_of_day

          build_cache(new_start_day, new_end_day)
          
        end
      end
      
      def create_cache_record

        build_sensor_event_count(false)
        build_proto_counts

        @cache.update({
                        :event_count => fetch_event_count,
                        :tcp_count => fetch_tcp_count,
                        :udp_count => fetch_udp_count,
                        :icmp_count => fetch_icmp_count,
                        :classification_metrics => fetch_classification_metrics,
                        :severity_metrics => fetch_severity_metrics(false),
                        :src_ips => fetch_src_ip_metrics,
                        :dst_ips => fetch_dst_ip_metrics,
                        :signature_metrics => fetch_signature_metrics(false)
        })

        @cache
      end

    end
  end
end
