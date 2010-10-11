require 'dm-core'
require 'snorby/packet/payload'
# # require 'ipaddr'

module Snorby
  module Model
    module Types
      
      class PayloadText < DataMapper::Property::Text

        def load(payload)
          [payload].pack('H*')
        end

        def dump(payload)
          [payload].pack('H*')
        end

        def typecast(payload)
          [payload].pack('H*')
        end

      end
    end
  end
end