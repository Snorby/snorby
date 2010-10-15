require 'snorby/model'
require 'snorby/packet'

class Payload
  
  include Snorby::Model
  include DataMapper::Resource

  storage_names[:default] = "data"
  
  belongs_to :sensor, :parent_key => [ :sid ], :child_key => [ :sid ], :required => true
  
  belongs_to :event, :parent_key => [ :sid, :cid ], :child_key => [ :sid, :cid ], :required => true
  
  property :sid, Integer, :key => true, :index => true
  
  property :cid, Integer, :key => true, :index => true
  
  property :data_payload, PayloadText


  def to_s
    Snorby::Packet::Payload.dump([data_payload].pack('H*'), :width => 20, :format => :twos, :annotate => :ascii)
  end

end
