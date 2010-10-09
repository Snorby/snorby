class Udp

  include DataMapper::Resource

  storage_names[:default] = "udphdr"

  belongs_to :sensor, :parent_key => [ :sid ], :child_key => [ :sid ], :required => true
  
  belongs_to :event, :parent_key => [ :sid, :cid ], :child_key => [ :sid, :cid ], :required => true

  property :sid, Integer, :key => true
  
  property :cid, Integer, :key => true
  
  property :udp_sport, Integer
  
  property :udp_dport, Integer

  property :udp_len, Integer
  
  property :udp_csum, Integer

end
