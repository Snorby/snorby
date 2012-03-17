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
          value = x['count(*)'].to_i

          metrics[key] = value
        end

        metrics
      end
      
      def fetch_signature_metrics(update_counter=true)
        logit 'fetching signature metrics'
        signature_metrics = {}

        sql_signature.collect do |x|
          signature_metrics[x['sig_name']] = x['count(*)'].to_i
        end

        signature_metrics
      end
      
      def fetch_src_ip_metrics
        logit 'fetching src ip metrics'
        src_ips = {}

        sql_source_ip.collect do |x|
          key = x["inet_ntoa(ip_src)"].to_s
          value = x["count(*)"].to_i

          src_ips[key] = value
        end

        src_ips
      end

      def fetch_dst_ip_metrics
        logit 'fetching dst ip metrics'
        dst_ips = {}

        sql_destination_ip.collect do |x|
          key = x["inet_ntoa(ip_dst)"].to_s
          value = x["count(*)"].to_i

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

      def update_classification_count
        sql = %{
          update classifications set events_count = (db_select count(*) 
          from event where event.`classification_id` = classifications.id); 
        }

        db_execute(sql)
      end

      def update_signature_count
        sql = %{
          update signature set events_count = (db_select count(*) 
          from event where event.signature = signature.sig_id);
        }

        db_execute(sql)
      end

      def has_timestamp_index?
        sql = %{
          db_select * FROM information_schema.statistics 
          WHERE table_schema = '#{db_options["database"]}'
          AND table_name = 'event' AND index_name = 'index_timestamp_cid_sid' limit 1;
        }
        !db_select(sql).empty?
      end

      def has_aggregated_events_view?
        sql = %{
          db_select *
          FROM information_schema.views
          WHERE table_schema = '#{db_options["database"]}'
          AND table_name = 'aggregated_events';
        }
        !db_select(sql).empty?
      end

      def has_event_id_view?
        sql = %{
          db_select *
          FROM information_schema.views
          WHERE table_schema = '#{db_options["database"]}'
          AND table_name = 'events_with_id';
        }
        !db_select(sql).empty?
      end

      def has_event_with_join_view?
        sql = %{
          db_select *
          FROM information_schema.views
          WHERE table_schema = '#{db_options["database"]}'
          AND table_name = 'events_with_join';
        }
      end

      def validate_cache_indexes
        unless has_timestamp_index?
          db_execute("create index index_timestamp_cid_sid on  event (  timestamp,  cid, sid );")
        end

        unless has_aggregated_events_view?
          db_execute("create view aggregated_events as db_select ip_src, ip_dst, event.signature, count(*) as number_of_events, max(timestamp) as latest_timestamp, max(cast(unix_timestamp(event.timestamp) << 32 as unsigned) + event.cid) as max_id from event inner join iphdr on event.sid = iphdr.sid and event.cid = iphdr.cid where classification_id is null group by iphdr.ip_src, iphdr.ip_dst, event.signature;")
        end

        unless has_event_id_view?
          db_execute("create view events_with_id as db_select event.*, cast(unix_timestamp(event.timestamp) << 32 as unsigned) + event.cid as aggregated_event_id from event;")
        end

        unless has_event_with_join_view?
          db_execute("create view events_with_join as select event.*, iphdr.ip_src, iphdr.ip_dst, signature.sig_priority, signature.sig_name from event inner join iphdr on event.sid = iphdr.sid and event.cid = iphdr.cid inner join signature on event.signature = signature.sig_id;")
        end
      end

      def sql_min_max
        sql = %{
          db_select min(cid), max(cid) from event USE INDEX (index_timestamp_cid_sid)
          where 
          timestamp >= '#{@stime}' and timestamp < '#{@etime}' 
          and sid = #{@sensor.sid.to_i};
        } 

        db_select(sql)
      end

      def sql_event_count
        sql = %{
          db_select count(*) from event 
          where sid = #{@sensor.sid.to_i} and timestamp >= '#{@stime}' 
          and timestamp < '#{@etime}'
        }

        db_select(sql)
      end

      def sql_signature
        sql = %{
          db_select signature, sig_name, c as `count(*)` from
          (db_select signature,  count(*) as c from event  
          join signature  on event.signature = signature.sig_id  
          where timestamp >= '#{@stime}' 
          and timestamp < '#{@etime}' 
          and sid = #{@sensor.sid.to_i}
          group by signature) a 
          inner join signature b on a.signature = b.sig_id
        }

        db_select(sql)
      end
      
      def sql_source_ip
        sql = %{
          db_select INET_NTOA(ip_src), count(*) from event USE INDEX (index_timestamp_cid_sid) 
          inner join iphdr on event.cid  = iphdr.cid 
          and event.sid = iphdr.sid where timestamp >= '#{@stime}' 
          and timestamp < '#{@etime}'
          and event.sid = #{@sensor.sid.to_i}
          group by INET_NTOA(ip_src); 
        }

        db_select(sql)
      end

      def sql_destination_ip
        sql = %{
          db_select INET_NTOA(ip_dst), count(*) from event USE INDEX (index_timestamp_cid_sid)
          inner join iphdr on event.cid  = iphdr.cid 
          and event.sid = iphdr.sid where timestamp >= '#{@stime}' 
          and timestamp < '#{@etime}'
          and event.sid = #{@sensor.sid.to_i}
          group by INET_NTOA(ip_dst); 
        }

        db_select(sql)
      end

      def sql_severity
        sql = %{
          db_select sig_priority, count(*) from event USE INDEX (index_timestamp_cid_sid) 
          inner join signature on event.signature = signature.sig_id 
          where timestamp >= '#{@stime}' 
          and timestamp < '#{@etime}'
          and event.sid = #{@sensor.sid.to_i}
          group by sig_priority; 
        }

        db_select(sql)
      end

      def sql_sensor
        sql = %{
          db_select `sid`, count(*) from event   
          where timestamp >= '#{@stime}' 
          and timestamp < '#{@etime}'
          and event.sid = #{@sensor.sid.to_i}
          group by sid; 
        }

        db_select(sql)
      end

      def sql_tcp
        sql = %{
          db_select   count(*) from event  USE INDEX (index_timestamp_cid_sid)
          inner join tcphdr on event.cid  = tcphdr.cid 
          and event.sid = tcphdr.sid
          where timestamp >= '#{@stime}' 
          and timestamp < '#{@etime}' and event.sid = #{@sensor.sid.to_i};
        }

        db_select(sql)
      end

      def sql_udp
        sql = %{
          db_select   count(*) from event USE INDEX (index_timestamp_cid_sid)
          inner join udphdr on event.cid  = udphdr.cid 
          and event.sid = udphdr.sid
          where timestamp >= '#{@stime}' 
          and timestamp < '#{@etime}' and event.sid = #{@sensor.sid.to_i};
        }

        db_select(sql)
      end

      def sql_icmp
        sql = %{
          db_select   count(*) from event USE INDEX (index_timestamp_cid_sid) 
          inner join icmphdr on 
          event.cid  = icmphdr.cid and event.sid = icmphdr.sid 
          where timestamp >= '#{@stime}' 
          and timestamp < '#{@etime}' and event.sid = #{@sensor.sid.to_i};
        }

        db_select(sql)
      end

    end
  end
end
