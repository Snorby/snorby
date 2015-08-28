module Snorby
  module Jobs
    module CacheHelper

      BATCH_SIZE = 5000

      def logit(msg, show_sensor=true)
        if show_sensor
          STDOUT.puts "Sensor #{@sensor.sid}: #{msg}" if verbose
        else
          STDOUT.puts "#{msg}" if verbose
        end
      end

      def merged_records(records)
        data = {
          :event_count => records.collect {|x| x[:event_count] }.inject { |sum,item| sum + item },
          :tcp_count => records.collect {|x| x[:tcp_count] }.inject { |sum,item| sum + item },
          :udp_count => records.collect {|x| x[:udp_count] }.inject { |sum,item| sum + item },
          :icmp_count => records.collect {|x| x[:icmp_count] }.inject { |sum,item| sum + item },
          :severity_metrics => {},
          :src_ips => {},
          :dst_ips => {},
          :signature_metrics => {}
        }

        [
          :severity_metrics,
          :src_ips,
          :dst_ips,
          :signature_metrics
        ].each do |item|

          records.collect { |x| x[item] }.inject do |x,y|
          merge = {}
          keys = x.merge(y).keys

          keys.each do |key|
            if x.has_key?(key)
              merge[key] = y.has_key?(key) ? y[key] + x[key] : x[key]
            else
              merge[key] = y[key]
            end
          end

            data[item] = merge
          end
        end

        logit "merge completed successfully."
        data
      end

      def fetch_event_count
        logit 'fetching event count'
        sql_event_count.first.to_i
      end

      def fetch_tcp_count
        logit 'fetching tcp count'
        sql_tcp.first.to_i
      end

      def fetch_udp_count
        logit 'fetching udp count'
        sql_udp.first.to_i
      end

      def fetch_icmp_count
        logit 'fetching icmp count'
        sql_icmp.first.to_i
      end

      def build_sensor_event_count(update_counter=true)
        logit 'fetching sensor metrics'
        @sensor.reload
        count = @sensor.events_count + @events.size
        @sensor.update!(:events_count => count) if update_counter
        count
      end

      def fetch_severity_metrics(update_counter=true)
        logit 'fetching severity metrics'
        metrics = {}

        sql_severity.collect do |x|
          key = x['sig_priority'].to_i
          value = x['count'].to_i

          metrics[key] = value
        end

        metrics
      end

      def fetch_signature_metrics(update_counter=true)
        logit 'fetching signature metrics'
        signature_metrics = {}

        sql_signature.collect do |x|
          signature_metrics[x['sig_name']] = x['c'].to_i
        end

        signature_metrics
      end

      def fetch_src_ip_metrics
        logit 'fetching src ip metrics'
        src_ips = {}

        sql_source_ip.collect do |x|
          key = x["inet_ntoa"].to_s
          value = x["count"].to_i

          src_ips[key] = value
        end

        src_ips
      end

      def fetch_dst_ip_metrics
        logit 'fetching dst ip metrics'
        dst_ips = {}

        sql_destination_ip.collect do |x|
          key = x["inet_ntoa"].to_s
          value = x["count"].to_i

          dst_ips[key] = value
        end

        dst_ips
      end

      def db_adapter
        @adapter ||= DataMapper.repository(:default).adapter
      end

      #
      # DM db_select
      #
      def db_select(sql, *args)
        db_adapter.select(sql, *args)
      end

      #
      # DM db_execute
      #
      def db_execute(sql, *args)
        db_adapter.execute(sql, *args)
      end

      def db_options
        @db_options ||= DataMapper.repository.adapter.options
      end

      def clean_old_data
        sql = [
          "DELETE FROM data USING data LEFT OUTER JOIN event USING (sid,cid) WHERE event.sid IS NULL;",
          "DELETE FROM iphdr USING iphdr LEFT OUTER JOIN event USING (sid,cid) WHERE event.sid IS NULL;",
          "DELETE FROM tcphdr USING tcphdr LEFT OUTER JOIN event USING (sid,cid) WHERE event.sid IS NULL;",
          "DELETE FROM icmphdr USING icmphdr LEFT OUTER JOIN event USING (sid,cid) WHERE event.sid IS NULL;"
        ]
        sql.each do |x|
          db_execute(x)
        end
      end

      def delete_sensor(sensor_id)
        sql = [
          "delete from agent_asset_names where sensor_sid = #{sensor_id.to_i};",
          "delete from caches where sid = #{sensor_id.to_i};",
          "delete from data where sid = #{sensor_id.to_i};",
          "delete from favorites where sid = #{sensor_id.to_i};",
          "delete from icmphdr where sid = #{sensor_id.to_i};",
          "delete from iphdr where sid = #{sensor_id.to_i};",
          "delete from notes where sid = #{sensor_id.to_i};",
          "delete from opt where sid = #{sensor_id.to_i};",
          "delete from tcphdr where sid = #{sensor_id.to_i};",
          "delete from udphdr where sid = #{sensor_id.to_i};",
          "delete from event where sid = #{sensor_id.to_i};",
          "delete from sensor where sid = #{sensor_id.to_i};"
        ]

        sql.each do |x|
          db_execute(x)
        end
      end

      def update_classification_count
        sql = %{
          update classifications set events_count = (select count(*) as count
          from event where event.classification_id = classifications.id);
        }

        db_execute(sql)
      end

      def update_signature_count
        sql = %{
          update signature set events_count = (select count(*) as count
          from event where event.signature = signature.sig_id);
        }

        db_execute(sql)
      end


      def validate_cache_indexes
        puts "[~] Building aggregated_events database view"
        db_execute("create or replace view aggregated_events AS select iphdr.ip_src AS ip_src, iphdr.ip_dst AS ip_dst, event.signature AS signature,max(event.id) AS event_id,count(0) AS number_of_events from (event join iphdr on(((event.sid = iphdr.sid) and (event.cid = iphdr.cid)))) where event.classification_id IS NULL group by iphdr.ip_src,iphdr.ip_dst,event.signature;")

        puts "[~] Building events_with_join database view"
        db_execute("create or replace view events_with_join as select event.*, iphdr.ip_src, iphdr.ip_dst, signature.sig_priority, signature.sig_name from event inner join iphdr on event.sid = iphdr.sid and event.cid = iphdr.cid inner join signature on event.signature = signature.sig_id;")

        adapter_type = db_adapter().class.name.split("::").last()
        if adapter_type == "PostgresAdapter"
          # work based off https://github.com/intgr/mysqlcompat
          puts "[~] Building inet_aton and inet_ntoa functions for postgresql"
          db_execute("CREATE OR REPLACE FUNCTION inet_aton(text)
                      RETURNS bigint AS $$
                        DECLARE
                            a text[];
                            b text[4];
                            up int;
                            family int;
                            i int;
                        BEGIN
                            IF position(':' in $1) > 0 THEN
                              family = 6;
                            ELSE
                              family = 4;
                            END IF;
                            -- mysql doesn't support IPv6 yet, it seems
                            IF family = 6 THEN
                              RETURN NULL;
                            END IF;
                            a = pg_catalog.string_to_array($1, '.');
                            up = array_upper(a, 1);
                            IF up = 4 THEN
                              -- nothing to do
                              b = a;
                            ELSIF up = 3 THEN
                              -- 127.1.2 = 127.1.0.2
                              b = array[a[1], a[2], '0', a[3]];
                            ELSIF up = 2 THEN
                              -- 127.1 = 127.0.0.1
                              b = array[a[1], '0', '0', a[2]];
                            ELSIF up = 1 THEN
                              -- 127 = 0.0.0.127
                              b = array['0', '0', '0', a[1]];
                            END IF;
                            i = 1;
                            -- handle 127..1
                            WHILE i <= 4 LOOP
                              IF length(b[i]) = 0 THEN
                                b[i] = '0';
                              END IF;
                              i = i + 1;
                            END LOOP;
                            RETURN (b[1]::bigint << 24) | (b[2]::bigint << 16) |
                                    (b[3]::bigint << 8) | b[4]::bigint;
                        END
                    $$ IMMUTABLE STRICT LANGUAGE PLPGSQL;")
          db_execute("CREATE OR REPLACE FUNCTION inet_ntoa(bigint)
                    RETURNS text AS $$
                    SELECT CASE WHEN $1 > 4294967295 THEN NULL ELSE
                        ((($1::bigint >> 24) % 256) + 256) % 256 operator(pg_catalog.||) '.' operator(pg_catalog.||)
                        ((($1::bigint >> 16) % 256) + 256) % 256 operator(pg_catalog.||) '.' operator(pg_catalog.||)
                        ((($1::bigint >>  8) % 256) + 256) % 256 operator(pg_catalog.||) '.' operator(pg_catalog.||)
                        ((($1::bigint      ) % 256) + 256) % 256 END;
                    $$ IMMUTABLE STRICT LANGUAGE SQL;")
        end

      end
      alias :checkdb :validate_cache_indexes

      def sql_min_max
        sql = %{
          select min(cid), max(cid) from event
          where
          timestamp >= '#{@stime.strftime("%Y-%m-%d %H:%M:%S")}' and timestamp < '#{@etime.strftime("%Y-%m-%d %H:%M:%S")}'
          and sid = #{@sensor.sid.to_i};
        }

        db_select(sql)
      end

      def to_db_time(time)
        time.strftime("%Y-%m-%d %H:%M:%S")
      end

      def sql_event_count
        sql = %{
          select count(*) as count from event
          where sid = #{@sensor.sid.to_i} and timestamp >= '#{to_db_time(@stime)}'
          and timestamp < '#{to_db_time(@etime)}'
        }

        db_select(sql)
      end

      def sql_signature
        sql = %{
          select signature, sig_name, count(*) as count from event
          join signature  on event.signature = signature.sig_id
          where timestamp >= '#{to_db_time(@stime)}'
          and timestamp < '#{to_db_time(@etime)}'
          and sid = #{@sensor.sid.to_i}
          group by signature, sig_name
        }

        db_select(sql)
      end

      def sql_source_ip
        sql = %{
          select inet_ntoa(ip_src), count(*) as count from event
          inner join iphdr on event.cid  = iphdr.cid
          and event.sid = iphdr.sid where timestamp >= '#{to_db_time(@stime)}'
          and timestamp < '#{to_db_time(@etime)}'
          and event.sid = #{@sensor.sid.to_i}
          group by inet_ntoa(ip_src);
        }

        db_select(sql)
      end

      def sql_destination_ip
        sql = %{
          select inet_ntoa(ip_dst), count(*) as count from event
          inner join iphdr on event.cid  = iphdr.cid
          and event.sid = iphdr.sid where timestamp >= '#{to_db_time(@stime)}'
          and timestamp < '#{to_db_time(@etime)}'
          and event.sid = #{@sensor.sid.to_i}
          group by inet_ntoa(ip_dst);
        }

        db_select(sql)
      end

      def sql_severity
        sql = %{
          select sig_priority, count(*) as count from event
          inner join signature on event.signature = signature.sig_id
          where timestamp >= '#{to_db_time(@stime)}'
          and timestamp < '#{to_db_time(@etime)}'
          and event.sid = #{@sensor.sid.to_i}
          group by sig_priority;
        }

        db_select(sql)
      end

      def sql_sensor
        sql = %{
          select sid, count(*) as count from event
          where timestamp >= '#{to_db_time(@stime)}'
          and timestamp < '#{to_db_time(@etime)}'
          and event.sid = #{@sensor.sid.to_i}
          group by sid;
        }

        db_select(sql)
      end

      def sql_tcp
        sql = %{
          select count(*) as count from event
          inner join tcphdr on event.cid  = tcphdr.cid
          and event.sid = tcphdr.sid
          where timestamp >= '#{to_db_time(@stime)}'
          and timestamp < '#{to_db_time(@etime)}' and event.sid = #{@sensor.sid.to_i};
        }

        db_select(sql)
      end

      def sql_udp
        sql = %{
          select count(*) as count from event
          inner join udphdr on event.cid  = udphdr.cid
          and event.sid = udphdr.sid
          where timestamp >= '#{to_db_time(@stime)}'
          and timestamp < '#{to_db_time(@etime)}' and event.sid = #{@sensor.sid.to_i};
        }

        db_select(sql)
      end

      def sql_icmp
        sql = %{
          select count(*) as count from event
          inner join icmphdr on
          event.cid  = icmphdr.cid and event.sid = icmphdr.sid
          where timestamp >= '#{to_db_time(@stime)}'
          and timestamp < '#{to_db_time(@etime)}' and event.sid = #{@sensor.sid.to_i};
        }

        db_select(sql)
      end

      def latest_five_distinct_signatures
        sql = %{
          select signature from (
            select signature, MAX(timestamp) as timestamp from event group by signature,timestamp order by timestamp desc limit 5
          ) as signature;
        }

        db_select(sql)
      end

    end
  end
end
