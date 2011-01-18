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