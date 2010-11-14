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

    class SensorCache < Struct.new(:verbose)

      attr_accessor :events, :last_cache, :cache, :last_event

      def perform
        begin

          Sensor.all.each do |sensor|
            @sensor = sensor

            logit "Looking for events..."
            @pager_events = since_last_cache
            
            puts @pager_events.map(&:sid).uniq
            
            @pager = @pager_events.page(0, :per_page => 10000, :order => [:timestamp.asc]).pager

            split_events_and_process

          end
          
          Snorby::Jobs.sensor_cache.destroy! if Snorby::Jobs.sensor_cache?
          Delayed::Job.enqueue(Snorby::Jobs::SensorCache.new(false), 1, Time.now + 30.minute)
        rescue => e
          logit "ERROR - #{e}"
          exit -1
        rescue Interrupt, IRB::Abort
          @cache.destroy! if defined?(@cache)
        end
      end

      private

        def logit(msg)
          STDOUT.puts "Sensor #{@sensor.sid}: #{msg}" if verbose
        end

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

        def fetch_event_count
          logit '- fetch_event_count'
          @events.size
        end

        def build_proto_counts
          logit '- building proto counts'

          @events.each do |event|

            if event.tcp?
              @tcp_events << event
            elsif event.udp?
              @udp_events << event
            else
              @icmp_events << event
            end

          end
        end

        def fetch_tcp_count
          logit '- fetching tcp count'
          @tcp_events.size
        end

        def fetch_udp_count
          logit '- fetching udp count'
          @udp_events.size
        end

        def fetch_icmp_count
          logit '- fetching icmp count'
          @icmp_events.size
        end

        def build_sensor_event_count
          logit '- fetching sensor metrics'
          @sensor.reload
          count = @sensor.events_count + @events.size
          @sensor.update!(:events_count => count)
          count
        end

        def fetch_classification_metrics
          logit '- fetching classification metrics'
          metrics = {}
          Classification.all.each do |classification|
            metrics[classification.id] = @events.all(:classification_id => classification.id).size
          end
          metrics
        end

        def fetch_severity_metrics
          logit '- fetching severity metrics'
          severity = @events.map(&:signature).map(&:sig_priority)
          metrics = {}
          Severity.all.each do |sev|
            if severity.include?(sev.id)
              metrics[sev.id] = severity.collect { |s| s if s == sev.id }.compact.size
              sev.update!(:events_count => sev.events_count + metrics[sev.id])
            end
          end
          metrics
        end
        
        def fetch_signature_metrics
          logit '- fetching signature metrics'
          metrics = {}
          Signature.all.each do |sig|
            sig_count = @events.all(:sig_id => sig.sig_id).size
            metrics[sig.sig_id] = sig_count
            sig.update!(:events_count => sig.events_count + sig_count)
          end
          metrics
        end

        def since_last_cache
          return Event.all(:sid => @sensor.sid) if @sensor.caches.blank?
          @last_cache = @sensor.caches.last
          Event.all(:timestamp.gt => @last_cache.ran_at).all(:sid => @sensor.sid)
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
        def split_events_and_process

          logit 'Splitting Events for processing...'
          logit "TOTAL COUNT: #{@pager.total_pages}/#{@pager.total}"

          total_page_count = @pager.total_pages + 1
          total_page_count.times do |count|
            next if count.zero?

            @tcp_events = []
            @udp_events = []
            @icmp_events = []

            logit "COUNT: #{count}"

            @events = @pager_events.page(count, :per_page => 10000, :order => [:timestamp.asc])

            @last_event = @events.last unless @events.blank?

            logit 'Found events - processing...'

            if defined?(@last_cache)
              logit 'Found last cache...'
              @last_cache = @sensor.caches.last
              @cache = Cache.create(:sid => @last_event.sid, :cid => @last_event.cid, :ran_at => @last_event.timestamp)
            else
              logit 'No cache records found - creating first cache record...'
              reset_counter_cache_columns
              @last_cache = Cache.create(:sid => @last_event.sid, :cid => @last_event.cid, :ran_at => @last_event.timestamp)
              @cache = @last_cache
            end

            logit 'Building cache attributes'

            build_snorby_cache

          end


        end

    end

  end
end
