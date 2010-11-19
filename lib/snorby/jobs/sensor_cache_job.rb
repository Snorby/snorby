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

    class SensorCacheJob < Struct.new(:verbose)

      include Snorby::Jobs::CacheHelper
      attr_accessor :events, :last_cache, :cache, :last_event

      def perform
        begin

          current_hour = Time.now.beginning_of_day + Time.now.hour.hours
          half_past_time = current_hour + 30.minutes

          if half_past_time < Time.now
            @stop_time = half_past_time
          else
            @stop_time = current_hour
          end

          puts "Cache Stop Time: #{@stop_time}"

          Sensor.all.each do |sensor|
            @sensor = sensor

            logit "Looking for events..."
            @since_last_cache = since_last_cache
            
            next if @since_last_cache.blank?

            start_time = @since_last_cache.first.timestamp.beginning_of_day + @since_last_cache.first.timestamp.hour.hours
            end_time = start_time + 30.minute

            split_events_and_process(start_time, end_time)

          end

          Delayed::Job.enqueue(Snorby::Jobs::SensorCacheJob.new(false), 1, @stop_time + 30.minute)

        rescue Interrupt
          @cache.destroy! if defined?(@cache)
        end
      end

      private

        def build_snorby_cache

          build_sensor_event_count
          build_proto_counts

          @cache.update({
                          :event_count => fetch_event_count,
                          :tcp_count => fetch_tcp_count,
                          :udp_count => fetch_udp_count,
                          :icmp_count => fetch_icmp_count,
                          :classification_metrics => fetch_classification_metrics,
                          :severity_metrics => fetch_severity_metrics,
                          :signature_metrics => fetch_signature_metrics
          })

          @cache
        end

        def since_last_cache
          return Event.all(:sid => @sensor.sid) if @sensor.cache.blank?
          @last_cache = @sensor.cache.last
          Event.all(:timestamp.gte => @last_cache.ran_at).all(:sid => @sensor.sid)
        end

        def reset_counter_cache_columns
          Severity.update!(:events_count => 0)
          Sensor.update!(:events_count => 0)
          Signature.update!(:events_count => 0)
        end

        #
        # Do to a stackerror with large collections we
        # need to first split the results into smaller
        # collections of 10000 then continue with the
        # cache calculations.
        #
        def split_events_and_process(start_time, end_time)

          return if start_time >= @stop_time

          logit 'Splitting Events for processing...'

          puts "Event Start Time: #{start_time}"
          puts "Event Stop Time: #{end_time}"

          @events = @since_last_cache.between_time(start_time, end_time)

          @tcp_events = []
          @udp_events = []
          @icmp_events = []

          @last_event = @events.last

          if @events.blank?
            
             Cache.create(:sid => @sensor.sid, :ran_at => end_time)
            
          else
            
            logit 'Found events - processing...'

            if defined?(@last_cache)
              logit 'Found last cache...'
              @last_cache = @sensor.cache.last
              @cache = Cache.create(:sid => @last_event.sid, :cid => @last_event.cid, :ran_at => end_time)
            else
              logit 'No cache records found - creating first cache record...'
              reset_counter_cache_columns
              @last_cache = Cache.create(:sid => @last_event.sid, :cid => @last_event.cid, :ran_at => end_time)
              @cache = @last_cache
            end

            logit 'Building cache attributes'

            build_snorby_cache
            
          end

          new_start_time = end_time
          new_end_time = end_time + 30.minutes

          split_events_and_process(new_start_time, new_end_time)

        end

    end

  end
end