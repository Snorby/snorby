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

require 'dm-core'

module Snorby
  module Model
    module Types
      
      class NumericIPAddr < DataMapper::Property::Integer

        def load(ip)
          case ip
          when nil, 0
            nil
          else
            ::IPAddr.new(ip,Socket::AF_INET)
          end
        end

        def dump(ip)
          ip.to_i unless ip.nil?
        end

        def typecast(ip)
          if ip.kind_of?(Integer)
            ::IPAddr.new(ip,Socket::AF_INET)
          elsif (ip.kind_of?(String) && !(ip.empty?))
            ::IPAddr.new(ip)
          elsif ip.kind_of?(::IPAddr)
            ip
          end
        end

      end
    end
  end
end
