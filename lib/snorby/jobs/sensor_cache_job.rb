module Snorby
  module Jobs

    class SensorCacheJob < Struct.new(:verbose)

      include Snorby::Jobs::CacheHelper
      attr_accessor :events, :last_cache, :cache, :last_event

      def perform

          Signal.trap("INT") do 
            if defined?(@cache)
              p @cache
              @cache.destroy! 
            end
            raise("SensorCacheJob Failed")
          end

          Signal.trap("TERM") do
            if defined?(@cache)
              p @cache
              @cache.destroy! 
            end
            raise("SensorCacheJob Failed")
          end

          current_hour = DateTime.now.beginning_of_day + DateTime.now.hour.hours
          half_past_time = current_hour + 30.minutes

          if half_past_time < DateTime.now
            @stop_time = half_past_time 
          else
            @stop_time = current_hour
          end

          Sensor.all.each do |sensor|
            @sensor = sensor

            @since_last_cache = since_last_cache

            if @since_last_cache.compact.empty? #|| @since_last_cache.first.nil?

              if @sensor.cache.first.blank?

                current_hour = DateTime.now.beginning_of_day + DateTime.now.hour.hours
                half_past_time = current_hour + 30.minutes

                if half_past_time < DateTime.now
                  start_time = half_past_time
                else
                  start_time = current_hour
                end

              else
                last_run = @sensor.cache.last.ran_at

                start_time = if last_run > DateTime.now
                  @sensor.cache.last.ran_at - 30.minutes
                else
                  @sensor.cache.last.ran_at
                end

              end

              logit "Building Empty Cache - #{start_time} - #{@stop_time}"
              tmp = Cache.first_or_create(:sid => @sensor.sid, :ran_at => start_time)
              tmp.update(:updated_at => DateTime.now)
              #next
            end

            #
            # This will fail if the sensor has no events
            #

            # Prevent Duplicate Cache Records
            if @sensor.cache.first.blank?
              
              start_time = @since_last_cache.first.timestamp.beginning_of_day + 
                @since_last_cache.first.timestamp.hour.hours

              end_time = start_time + 30.minute

              next if start_time > @stop_time
            else
              last_run = @sensor.cache.last.ran_at

              start_time = if last_run > DateTime.now
                @sensor.cache.last.ran_at - 30.minutes
              else
                @sensor.cache.last.ran_at
              end


              end_time = start_time + 30.minute

              next if (start_time > @stop_time)
            end

            #
            # Process
            #
            while (start_time < end_time) do
              @stime = start_time
              @etime = end_time

              break if start_time > @stop_time

              split_events_and_process(start_time, end_time)

              start_time = end_time
              end_time = end_time + 30.minutes
            end

          end # Sensor.all.each END

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


          Snorby::Jobs.sensor_cache.destroy! if Snorby::Jobs.sensor_cache?

          Delayed::Job.enqueue(Snorby::Jobs::SensorCacheJob.new(false), 
          :priority => 1, :run_at => DateTime.now + 10.minutes)

      rescue => e
        puts e
        puts e.backtrace
        @cache.destroy! if defined?(@cache)
      end

      private

        def since_last_cache
          return [Event.all(:sid => @sensor.sid).first] if @sensor.cache.first.blank?

          @last_cache = @sensor.cache.last
          time = if @last_cache.ran_at > DateTime.now
            @last_cache.ran_at - 30.minutes
          else
            @last_cache.ran_at
          end

          [Event.all(:sid => @sensor.sid, :timestamp.gte => time).first]
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

          event = db_select(%{
            select cid from event where timestamp >= '#{@stime.to_s(:db)}' 
            and timestamp < '#{@etime.to_s(:db)}' and sid = #{@sensor.sid.to_i} 
            order by timestamp desc limit 1
          })

          if event.empty?

            logit "\nTime: #{start_time} - #{end_time}", false
            logit "no events - building empty cache record"
            tmp = Cache.first_or_create(:sid => @sensor.sid, :ran_at => start_time)
            tmp.update(:updated_at => DateTime.now)

          else

            if defined?(@last_cache)
              @last_cache = @sensor.cache.last
              @cache = Cache.first_or_create(:sid => @sensor.sid, :ran_at => start_time)

            else
              logit 'No cache records found - creating first cache record...'
              reset_counter_cache_columns
              
              @last_cache = Cache.first_or_create(:sid => @sensor.sid, :ran_at => start_time)
              @cache = @last_cache
            end

            logit "\nTime: #{start_time} - #{end_time}", false

            data = {
              :cid => event.first.to_i,
              :event_count => fetch_event_count,
              :tcp_count => fetch_tcp_count,
              :udp_count => fetch_udp_count,
              :icmp_count => fetch_icmp_count,
              :severity_metrics => fetch_severity_metrics,
              :src_ips => fetch_src_ip_metrics,
              :dst_ips => fetch_dst_ip_metrics,
              :signature_metrics => fetch_signature_metrics
            }


            @cache.update(data)
          end

        end

    end

  end
end

