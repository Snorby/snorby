module Snorby
  module Jobs
    class DailyCacheJob < Struct.new(:verbose)

      include Snorby::Jobs::CacheHelper

      class CacheCompleted < Exception; end;

      def perform
        Signal.trap("INT") do 
          if defined?(@cache)
            p @cache
            @cache.destroy! 
          end

          raise("DailyCacheJob Failed")
        end

        Signal.trap("TERM") do
          if defined?(@cache)
            p @cache
            @cache.destroy! 
          end

          raise("DailyCacheJob Failed")
        end

        @stop_date = DateTime.now.yesterday.end_of_day


        Sensor.all.each do |sensor|
          @sensor = sensor

          if @sensor.daily_cache.first.blank?

             sensor_event = Event.first(:sid => @sensor.sid)
        
             next if sensor_event.blank?
             
             day_start =  sensor_event.timestamp.beginning_of_day
             day_end = sensor_event.timestamp.end_of_day
          else

            day_start = @sensor.daily_cache.last.ran_at.tomorrow.beginning_of_day
            day_end = @sensor.daily_cache.last.ran_at.tomorrow.end_of_day
          end


          #
          # Process
          #
          while (day_start < day_end) do
            @stime = day_start
            @etime = day_end

            break if day_start >= @stop_date

            build_cache(day_start, day_end)

            day_start = (day_end + 1.day).beginning_of_day
            day_end = (day_end + 1.day).end_of_day
          end

        end


        begin

          logit "\n[~] Building Sensor Metrics", false
          Sensor.all.each do |x|
            x.update(:events_count => Event.all(:sid => x.sid).count)
          end

          logit "[~] Building Signature Metrics", false
          update_signature_count

          logit "[~] Building Classification Metrics", false
          update_classification_count

          logit "[~] Building Severity Metrics\n\n", false
          Severity.all.each do |x|
            x.update(:events_count => Event.all(:"signature.sig_priority" => x.sig_id).count)
          end

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
          
          logit "Dropping old events", false

          while Event.count > Setting.autodrop_count.value.to_i do
            autodrop = Event.all(:limit => 1000, :order => :timestamp.asc)
            autodrop.destroy!
          end
        end

        Snorby::Jobs.daily_cache.destroy! if Snorby::Jobs.daily_cache?

        Delayed::Job.enqueue(Snorby::Jobs::DailyCacheJob.new(false), 
                             :priority => 1, 
                             :run_at => Time.now.tomorrow.beginning_of_day)

      rescue => e
        puts e
        puts e.backtrace
        @cache.destroy! if defined?(@cache) 
      end

      def send_weekly_report
        ReportMailer.weekly_report.deliver if @stop_date.day == @stop_date.end_of_week.day
      end

      def send_monthly_report
        ReportMailer.monthly_report.deliver if @stop_date.day == @stop_date.end_of_month.day
      end

      def build_cache(day_start, day_end)

        event = db_select(%{
          select cid from event where timestamp >= '#{@stime.to_s(:db)}' 
          and timestamp < '#{@etime.to_s(:db)}' and sid = #{@sensor.sid.to_i} 
          order by timestamp desc limit 1
        })

        @cache = DailyCache.first_or_create(:ran_at => day_start, :sensor => @sensor)

        if event.empty?
          logit "\n No Events"
        else

          logit "\nNew Day: #{day_start} - #{day_end}", false

          data = {
            :event_count => fetch_event_count,
            :tcp_count => fetch_tcp_count,
            :udp_count => fetch_udp_count,
            :icmp_count => fetch_icmp_count,
            :severity_metrics => fetch_severity_metrics(false),
            :src_ips => fetch_src_ip_metrics,
            :dst_ips => fetch_dst_ip_metrics,
            :signature_metrics => fetch_signature_metrics(false)
          }

          @cache.update(data)
        end
      end

    end
  end
end
