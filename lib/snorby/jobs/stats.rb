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

    class Stats < Struct.new(:verbose)

      attr_accessor :events, :last_cache, :cache, :last_event

      @tcp_count = 0
      @udp_count = 0
      @icmp_count = 0

      def perform
        logit 'Looking for events...'
        @events = since_last_cache

        unless @events.blank?
          @last_event = @events.last unless @events.blank?
          
          logit 'Found events - processing...'
          
          if defined?(@last_cache)
            logit 'Found last cache...'
            @cache = Cache.create(:sid => @last_event.sid, :cid => @last_event.cid, :ran_at => @last_event.timestamp)
          else
            logit 'No cache records found - creating first cache record...'
            @last_cache = Cache.create(:sid => @last_event.sid, :cid => @last_event.cid, :ran_at => @last_event.timestamp)
            @cache = @last_cache
          end
          
          logit 'Building cache attributes'
          
          build_snorby_cache
          
          logit 'Done...'
        end

        Delayed::Job.enqueue(Snorby::Jobs::Stats.new(false), 1, Time.now + 30.minute)
      end

      private

        def logit(msg)
          STDOUT.puts "#{msg}" if verbose
        end

        # property :id, Serial
        # property :sid, Integer
        # property :cid, Integer
        # property :ran_at, DateTime
        # property :event_count, Integer
        # property :tcp_count, Integer
        # property :udp_count, Integer
        # property :icmp_count, Integer
        # property :total_src, Integer
        # property :total_dst, Integer
        # property :uniq_src, Integer
        # property :uniq_dst, Integer
        # property :port_metrics, Object
        # property :classification_metrics, Object
        # property :severity_metrics, Object

        def build_snorby_cache
          
          build_proto_counts
          
          @cache.update({
                          :event_count => fetch_event_count,
                          :tcp_count => fetch_tcp_count,
                          :udp_count => fetch_udp_count,
                          :icmp_count => fetch_icmp_count,
                          :severity_metrics => fetch_severity_metrics
          })
          # fetch_ip_metrics
          # fetch_port_metrics
          @cache
        end

        def fetch_event_count
          logit '- fetch_event_count'
          @last_cache.event_count + @events.count
        end
        
        def build_proto_counts
           logit '- building proto counts'
           
           @events.each do |event|
             
             if event.tcp?
               @tcp_count += 1
             elsif udp?
               @udp_count += 1
             else
               @icmp_count += 1
             end
             
           end
        end

        def fetch_tcp_count
          logit '- fetch_tcp_count'
          @tcp_events
        end

        def fetch_udp_count
          logit '- fetch_udp_count'
          @udp_events
        end

        def fetch_icmp_count
          logit '- fetch_icmp_count'
          @icmp_events
        end

        def fetch_ip_metrics
          
        end

        def fetch_port_metrics

        end

        def fetch_severity_metrics
          logit '- fetch_severity_metrics'
          
          severity = @events.map(&:signature).map(&:sig_priority)
          metrics = {}
          Severity.all.each do |sev|
            metrics[sev.name.to_sym] = severity.collect { |s| s if s == sev.id }.compact.size
            sev.event_count = sev.event_count + metrics[sev.name.to_sym]
            sev.save
          end
          metrics
        end

        def since_last_cache
          return Event.all if Cache.all.blank?
          @last_cache = Cache.last
          Event.all(:timestamp.gt => @last_cache.ran_at)
        end

    end

  end
end
