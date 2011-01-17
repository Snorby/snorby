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
    class Solera

      include Snorby::Plugins::Helpers

      def initialize(event, params={})

        @plugin_params = {
          :source_ip => :ipv4_source,
          :destination_ip => :ipv4_destination,
          :start_time => :start_time,
          :end_time => :end_time,
          :protocol => :ethernet_protocol,
          :source_port => :spt,
          :destination_port => :dpt
        }

        @event = event

        if @event.tcp?
          @plugin_params[:source_port] = :tcp_source_port
          @plugin_params[:destination_port] = :tcp_destination_port
        elsif @event.udp?
          @plugin_params[:source_port] = :udp_source_port
          @plugin_params[:destination_port] = :udp_destination_port
        else
          @plugin_params.delete(:source_port)
          @plugin_params.delete(:destination_port)
        end

        @params = standardize_parameters(params, @plugin_params)

        puts @params

        @url = Setting.packet_capture_url? ? Setting.find(:packet_capture_url) : '#'
      end

      def to_s
        "#{@url}?#{build_url_parameters}"
      end

      private

        def build_url_parameters

          if Setting.packet_capture_auto_auth?
            @params.merge!(:user => Setting.find(:packet_capture_user)) if Setting.packet_capture_user?
            @params.merge!(:password => Setting.find(:packet_capture_password)) if Setting.packet_capture_password?
          end

          if @params[:start_time].kind_of?(DateTime) || @params[:start_time].kind_of?(Time)
            @params[:start_time] = @params[:start_time].strftime('%m.%d.%Y.%H.%M.%S') if @params.has_key?(:start_time)
          end
          
          if @params[:end_time].kind_of?(DateTime) || @params[:end_time].kind_of?(Time)
            @params[:end_time] = @params[:end_time].strftime('%m.%d.%Y.%H.%M.%S') if @params.has_key?(:end_time)
          end

          convert_to_params
        end

    end
  end
end
