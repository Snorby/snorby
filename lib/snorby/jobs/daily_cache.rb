module Snorby
  module Jobs
    class DailyCache < Struct.new(:verbose)
      
      def perform

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