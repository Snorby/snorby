module Snorby
  module Plugins
    class Solera

      include Snorby::Plugins::Helpers

      def initialize(event, params={})
        @url = ""

        @plugin_params = {
          :source_ip => :source_ip,
          :destination_ip => :destination_ip,
          :start_time => :start_time,
          :end_time => :end_time,
          :protocol => :protocol,
          :source_port => :source_port,
          :destination_port => :destination_port,
          :method => :method
        }

        @event = event
        @params = standardize_parameters(params, @plugin_params)
      end

      def to_s
        "#{Setting.packet_capture_url? ? Setting.find(:packet_capture_url) : '#'}#{build_url_parameters}"
      end

      private

        def build_protocol_params
          if @params[:source_port] && @params[:destination_port]
            case @event.protocol.to_sym
            when :tcp
              @url += "/tcp_port"
              @url += "/#{@params[:source_port]}_and_#{@params[:destination_port]}"
            when :udp
              @url += "/udp_port"
              @url += "/#{@params[:source_port]}_and_#{@params[:destination_port]}"
            end
          end
        end
        
        def build_user_password_params(connector='&')
          if Setting.packet_capture_auto_auth?
            if Setting.packet_capture_user? && Setting.packet_capture_password?
              @url += "#{connector}user=#{Setting.find(:packet_capture_user)}"
              @url += "&password=#{Setting.find(:packet_capture_password)}"
            end
          end
        end
        
        def build_ip_params
          if @params[:source_ip] && @params[:destination_ip]
            @url += "/ipv4_address/#{@params[:source_ip]}_and_#{@params[:destination_ip]}"
          else
            unless (@params[:source_ip].nil? && @params[:destination_ip].nil?)
              @url += "/ipv4_address/"
              @url += "#{@params[:source_ip]}" if @params[:source_ip]
              @url += "#{@params[:destination_ip]}" if @params[:destination_ip]
            end
          end
        end

        def build_solera_pcap_url
          @url += "/ws/pcap?method=deepsee"
          @url += "&path=/timespan/#{@params[:start_time].strftime('%m.%d.%Y.%H.%M.%S')}-#{@params[:end_time].strftime('%m.%d.%Y.%H.%M.%S')}"

          build_protocol_params
          build_ip_params

          @url += "/data.pcap"
          
          build_user_password_params
        end

        def build_solera_deepsee_url
          @url += "/deepsee_reports"
          
          build_user_password_params('?')
          
          @url += "#pathString=/timespan/#{@params[:start_time].strftime('%m.%d.%Y.%H.%M.%S')}-#{@params[:end_time].strftime('%m.%d.%Y.%H.%M.%S')}"
          
          build_protocol_params
          build_ip_params
          
          @url += '/;reportIndex=0'
        end

        def build_url_parameters
          @params[:method] ||= :pcap
          
          case @params[:method].to_sym
          when :deepsee
            build_solera_deepsee_url
          when :pcap
            build_solera_pcap_url
          else
            build_solera_pcap_url
          end

          # PCAP:
          # https://$host:$port/ws/pcap?method=deepsee&path=/timespan/$start-$stop/$ipproto_port/$srcport_and_$dstport/ipv4_address/$srcip_and_$dstip/data.pcap&user=$usr&password=$pwd

          # DeepSee:
          # https://$host:$port/deepsee_reports?user=$usr&password=$pwd#pathString=/timespan/$start-$stop/$ipproto_port/$srcport_and_$dstport/ipv4_address/$srcip_and_$dstip/;reportIndex=0

          @url
        end

    end
  end
end
