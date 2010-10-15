require 'dm-core'
require 'snorby/packet/payload'
# # require 'ipaddr'

module Snorby
  module Model
    module Types
      
      class PayloadText < DataMapper::Property::Text

        def load(payload)
          payload
        end

        def dump(payload)
          payload
        end

        def typecast(payload)
          payload
        end

      end
    end
  end
end