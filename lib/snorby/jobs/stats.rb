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

    class Stats < Struct.new(:req)

      attr_accessor :events, :last_cache, :cache, :last_event

      @@tcp_events = []

      @@udp_events = []

      @@icmp_events = []

      def perform
        @events = since_last_cache

        unless @events.blank?
          @last_event = @events.last unless @events.blank?
          
          if defined?(@last_cache)
            @cache = Cache.create(:sid => @last_event.sid, :cid => @last_event.cid, :ran_at => @last_event.timestamp)
          else
            @last_cache = Cache.create(:sid => @last_event.sid, :cid => @last_event.cid, :ran_at => @last_event.timestamp)
            @cache = @last_cache
          end
          
          build_snorby_cache
        end

        Delayed::Job.enqueue(Snorby::Jobs::Stats.new(true), 1, Time.now + 30.minute)
      end

      private

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
          @last_cache.event_count + @events.count
        end

        def fetch_tcp_count
          @events.collect { |x| @@tcp_events << x if x.tcp? }
          @@tcp_events.size
        end

        def fetch_udp_count
          @events.collect { |x| @@udp_events << x if x.udp? }
          @@udp_events.size
        end

        def fetch_icmp_count
          @events.collect { |x| @@icmp_events << x if x.icmp? }
          @@icmp_events.size
        end

        def fetch_ip_metrics

        end

        def fetch_port_metrics

        end

        def fetch_severity_metrics
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
