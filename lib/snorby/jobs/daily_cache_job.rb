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
  module Jobs
    class DailyCacheJob < Struct.new(:verbose)

      include Snorby::Jobs::CacheHelper

      class CacheCompleted < Exception; end;

      def perform
        @stop_date = Time.now.yesterday.end_of_day

        begin

          if DailyCache.all.blank?

            unless Event.all.blank?

              day_start = Event.first.timestamp.beginning_of_day
              day_end = Event.first.timestamp.end_of_day

              Sensor.all.each do |sensor|
                @sensor = sensor
                build_cache(day_start, day_end)
              end

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

          begin

            send_weekly_report if Setting.weekly?
            send_monthly_report if Setting.monthly?
            ReportMailer.daily_report.deliver if Setting.daily?
             
          rescue PDFKit::NoExecutableError => e
            logit "#{e}"
          rescue => e
            logit "#{e}", false
            logit "#{e.backtrace.first}", false
            logit "Error: Unable to send report - please make sure your mail configurations are correct."
          end

          # Autodrop Logic
          if Setting.autodrop?
            if Event.count > Setting.autodrop_count.value.to_i
              autodrop = Event.all(:limit => Setting.autodrop_count.value.to_i, :order => :timestamp.asc)
              autodrop.destroy
            end
          end

          Snorby::Jobs.daily_cache.destroy! if Snorby::Jobs.daily_cache?

          Delayed::Job.enqueue(Snorby::Jobs::DailyCacheJob.new(false), 
                               :priority => 1, 
                               :run_at => Time.now.tomorrow.beginning_of_day)

        rescue Interrupt
          @cache.destroy! if defined?(@cache)
        end

      end

      def send_weekly_report
        ReportMailer.weekly_report.deliver if @stop_date.day == @stop_date.end_of_week.day
      end

      def send_monthly_report
        ReportMailer.monthly_report.deliver if @stop_date.day == @stop_date.end_of_month.day
      end

      def build_cache(day_start, day_end)

        all_events = Event.between(day_start, day_end).all(:sid => @sensor.sid)
        
        @tcp_events = []
        @udp_events = []
        @icmp_events = []

        if day_end >= @stop_date
          logit "Current - No New Events To Cache..."
          return
        end

        if all_events.blank?
          logit "Events Blank - No New Events To Cache..."

          new_time = day_end + 1.day
        else

          logit "\nNew Day: #{day_start} - #{day_end}", false
          logit "#{all_events.length} events found. Processing."

          @cache = DailyCache.create(:ran_at => day_start, :sensor => @sensor)
          records = []
          batch = 0

          all_events.each_chunk(BATCH_SIZE.to_i) do |chunk|
            @events = chunk
            
            logit "\nProcessing Batch #{batch += 1} of " + 
            "#{(all_events.length / BATCH_SIZE) + 1}...", false
            
            build_sensor_event_count(false)
            build_proto_counts

            data = {
              :event_count => fetch_event_count(true),
              :tcp_count => fetch_tcp_count,
              :udp_count => fetch_udp_count,
              :icmp_count => fetch_icmp_count,
              :severity_metrics => fetch_severity_metrics(false),
              :src_ips => fetch_src_ip_metrics,
              :dst_ips => fetch_dst_ip_metrics,
              :signature_metrics => fetch_signature_metrics(false)
            }

            records << data
          end

          if records.length > 1
            results = merged_records(records)
            @cache.update(results)
          else
            @cache.update(records.first)
          end
         
          new_time = all_events.last.timestamp.end_of_day + 1.day
        end

        new_start_day = new_time.beginning_of_day
          
        new_end_day = new_time.end_of_day

        build_cache(new_start_day, new_end_day)

      end

    end
  end
end
