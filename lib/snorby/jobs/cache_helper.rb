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
          signature_metrics[x['sig_name']] = x['count'].to_i
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

       def has_event_id?
        adapter_type = db_adapter().class.name.split("::").last()
        if adapter_type == "PostgresAdapter"
          sql = %{
            SELECT column_name FROM information_schema.columns WHERE table_name ='event' AND column_name = 'id';
          }
        else
          sql = %{
            SELECT * FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = '#{db_options["database"]}' AND TABLE_NAME = 'event' AND COLUMN_NAME = 'id';
          }
        end

        !db_select(sql).empty?
      end

      def is_bigint?(table, column)
        # this is only called from a postgres block
        sql = %{
          select data_type from information_schema.columns where table_name = '#{table}' and column_name='#{column}' and data_type='bigint';
        }
        !db_select(sql).empty?
      end

      def validate_cache_indexes


        unless has_event_id?
          puts "[~] Adding `id` to the event table"

          adapter_type = db_adapter().class.name.split("::").last()
          if adapter_type == "PostgresAdapter"
            db_execute("alter table event add column id bigserial;")
            db_execute("create index index_event_id on event (id);")
          else
            db_execute("alter table event add column id int;")
            db_execute("create index index_event_id on event (id);")
            db_execute("alter table event change column id id int not null auto_increment;")
          end
        end

        #check if the database is PostgreSQL and alter iphdr.ip_src, iphdr.ip_dst, tcphdr.seq, tcphdr.ack, icmphdr.seq to int8
        #Add INET_ATON & INET_NTOA functions to PostgreSQL
        #credit to https://github.com/challengemylimit
        adapter_type = db_adapter().class.name.split("::").last()
        if adapter_type == "PostgresAdapter"
          puts "[~] fixing database types for ip addresses"
          db_execute("DROP INDEX IF EXISTS index_iphdr_ip_src;");
          db_execute("DROP INDEX IF EXISTS index_iphdr_ip_dst;");
          unless is_bigint?('iphdr','ip_src')
            db_execute("ALTER TABLE iphdr ALTER COLUMN ip_src SET DATA TYPE int8;");
          end
          unless is_bigint?('iphdr','ip_dst')
            db_execute("ALTER TABLE iphdr ALTER COLUMN ip_dst SET DATA TYPE int8;");
          end
          unless is_bigint?('tcphdr','tcp_ack')
            db_execute("ALTER TABLE tcphdr ALTER COLUMN tcp_ack SET DATA TYPE int8;");
          end
          unless is_bigint?('tcphdr','tcp_seq')
            db_execute("ALTER TABLE tcphdr ALTER COLUMN tcp_seq SET DATA TYPE int8;");
          end
          unless is_bigint?('icmphdr','icmp_seq')
            db_execute("ALTER TABLE icmphdr ALTER COLUMN icmp_seq SET DATA TYPE int8;");
          end
          db_execute("create index index_iphdr_ip_src on iphdr (ip_src);");
          db_execute("create index index_iphdr_ip_dst on iphdr (ip_dst);");

          db_execute("CREATE OR REPLACE FUNCTION inet_aton(inet) RETURNS bigint AS 'select inetmi($1,''0.0.0.0'');' language sql immutable;");
          db_execute("CREATE OR REPLACE FUNCTION inet_ntoa(bigint) RETURNS inet AS 'select ''0.0.0.0''::inet+$1;' language sql immutable;");
        end

        puts "[~] Building aggregated_events database view"
        db_execute("create or replace view aggregated_events AS select iphdr.ip_src AS ip_src, iphdr.ip_dst AS ip_dst, event.signature AS signature,max(event.id) AS event_id,count(0) AS number_of_events from (event join iphdr on(((event.sid = iphdr.sid) and (event.cid = iphdr.cid)))) where event.classification_id IS NULL group by iphdr.ip_src,iphdr.ip_dst,event.signature;")

        puts "[~] Building events_with_join database view"
        db_execute("create or replace view events_with_join as select event.*, iphdr.ip_src, iphdr.ip_dst, signature.sig_priority, signature.sig_name from event inner join iphdr on event.sid = iphdr.sid and event.cid = iphdr.cid inner join signature on event.signature = signature.sig_id;")

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
          select inet_ntoa(ip_src) as inet_ntoa, count(*) as count from event
          inner join iphdr on event.cid  = iphdr.cid
          and event.sid = iphdr.sid where timestamp >= '#{to_db_time(@stime)}'
          and timestamp < '#{to_db_time(@etime)}'
          and event.sid = #{@sensor.sid.to_i}
          group by inet_ntoa;
        }

        db_select(sql)
      end

      def sql_destination_ip
        sql = %{
          select inet_ntoa(ip_dst) as inet_ntoa, count(*) as count from event
          inner join iphdr on event.cid  = iphdr.cid
          and event.sid = iphdr.sid where timestamp >= '#{to_db_time(@stime)}'
          and timestamp < '#{to_db_time(@etime)}'
          and event.sid = #{@sensor.sid.to_i}
          group by inet_ntoa;
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
