module Snorby
  module Plugins
    class OpenFPC

      include Snorby::Plugins::Helpers

      PLUGIN_PARAMS = {
        :source_ip => :sip,
        :destination_ip => :dip,
        :start_time => :stime,
        :end_time => :etime,
        :protocol => :proto,
        :source_port => :spt,
        :destination_port => :dpt
      }

      def initialize(event, params={})
        @event = event
        @params = standardize_parameters(params, PLUGIN_PARAMS)
        @url = Setting.packet_capture_url? ? Setting.find(:packet_capture_url) : '#'
      end

      def to_s
        "#{@url}?#{build_url_parameters}"
      end

      #
      # Build OpenFPC URL
      #
      # Append default settings for
      # the OpenFPC plugin
      #
      # retrun [Hash] OpenFPC url params
      #
      def build_url_parameters
        
        if Setting.packet_capture_auto_auth?
          @params.merge!(:user => Setting.find(:packet_capture_user)) if Setting.packet_capture_user?
          @params.merge!(:password => Setting.find(:packet_capture_password)) if Setting.packet_capture_password?
        end

        if @params.has_key?(:protocol)
          @params.merge!(:filename => "snorby-#{@params[:protocol]}-#{@event.ip.ip_src.to_i}#{@event.ip.ip_dst.to_i}")
        else
          @params.merge!(:filename => "snorby-#{@event.ip.ip_src.to_i}#{@event.ip.ip_dst.to_i}")
        end
        
        @params[:stime] = @params[:stime].to_i
        @params[:etime] = @params[:etime].to_i
        
        convert_to_params
      end

    end
  end
end
