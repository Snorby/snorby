require 'snorby/model/types'
require 'dm-core'

module Snorby
  module Model

    def self.included(base)
      base.send :include, DataMapper::Resource, 
                DataMapper::Migrations, Model::Types
    end

  end
end
