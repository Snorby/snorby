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
          :start_time => :stime,
          :end_time => :etime,
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

          convert_to_params
        end

    end
  end
end

# require 'rubygems'
# require 'soleranetworks'
#
#      options = {
#              :host                 =>    '192.168.20.20',
#              :user                 =>    'admin',
#              :pass                 =>    'somePassword',
#              :ipv4_address =>      '1.2.3.4',
#              :timespan             => (Time.now.getlocal-(60*5)).strftime('%m.%d.%Y.%H.%M.%S')+"."+Time.now.getlocal.strftime('%m.%d.%Y.%H.%M.%S')
#      }
#      request = SoleraNetworks.new(options)
#
#      # Generate API Call URI
#      puts request.uri
#      # https://192.168.20.20/ws/pcap?method=deepsee&user=admin&password=somePassword&path=%2Ftimespan%2F03.25.2010.14.14.37.03.25.2010.14.19.37%2Fipv4_address%2F1.2.3.4%2Fdata.pcap
