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
    module CacheHelper
      
      def logit(msg, show_sensor=true)
        if show_sensor
          STDOUT.puts "Sensor #{@sensor.sid}: #{msg}" if verbose
        else
          STDOUT.puts "#{msg}"
        end
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

      def build_sensor_event_count(update_counter=true)
        logit '- fetching sensor metrics'
        @sensor.reload
        count = @sensor.events_count + @events.size
        @sensor.update!(:events_count => count) if update_counter
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

      def fetch_severity_metrics(update_counter=true)
        logit '- fetching severity metrics'
        severity = @events.map(&:signature).map(&:sig_priority)
        metrics = {}
        Severity.all.each do |sev|
          if severity.include?(sev.id)
            metrics[sev.id] = severity.collect { |s| s if s == sev.id }.compact.size
            sev.update!(:events_count => sev.events_count + metrics[sev.id]) if update_counter
          end
        end
        metrics
      end
      
      def fetch_signature_metrics(update_counter=true)
        logit '- fetching signature metrics'
        metrics = {}
        Signature.all.each do |sig|
          sig_count = @events.all(:sig_id => sig.sig_id).size
          metrics[sig.sig_id] = sig_count
          sig.update!(:events_count => sig.events_count + sig_count) if update_counter
        end
        metrics
      end
      
      def fetch_src_ip_metrics
        logit '- fetching src ip metrics'
        # SOURCE
        metrics = {}
        ips = @events.ip.map(&:ip_src).uniq
        count = @events.ip.map(&:ip_src).uniq.size
        ips.each do |ip|
          @events.ip.all(:ip_src => ip)
        end
        metrics.merge!(:total_uniq_count => count)
      end

      def fetch_dst_ip_metrics
        logit '- fetching dst ip metrics'
        # DESTINATION
        metrics = {}
        ips = @events.ip.map(&:ip_dst).uniq
        count = @events.ip.map(&:ip_dst).uniq.size
        ips.each do |ip|
          @events.ip.all(:ip_dst => ip)
        end
        metrics.merge!(:total_uniq_count => count)
      end
      
    end
  end
end