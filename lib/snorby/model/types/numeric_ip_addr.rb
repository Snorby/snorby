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
