require 'dm-core'
require 'ipaddr'

module Snorby
  module Model
    module Types
      class NumericIPAddr < DataMapper::Property::Integer

        #
        # Loads a numeric IP Address.
        #
        # @param [Integer] ip
        #   The network encoded IP Address.
        #
        # @return [IPAddr, nil]
        #   The decoded IP address.
        #
        def load(ip)
          case ip
          when nil, 0
            nil
          else
            ::IPAddr.new(ip,Socket::AF_INET)
          end
        end

        #
        # Dumps the IP address.
        #
        # @param [IPAddr, nil]
        #   The IP address to dump.
        #
        # @return [Integer, nil]
        #   The network encoded IP address.
        #
        def dump(ip)
          ip.to_i unless ip.nil?
        end

        #
        # Typecasts an IP address.
        #
        # @param [IPAddr, String, Integer, nil] ip
        #   The IP address to typecast.
        #
        # @return [IPAddr, nil]
        #   The typecasted IP address.
        #
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