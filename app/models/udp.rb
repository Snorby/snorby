class Udp

  include DataMapper::Resource

  storage_names[:default] = "udphdr"

  belongs_to :sensor, :parent_key => [ :sid ], :child_key => [ :sid ], :required => true
  
  belongs_to :event, :parent_key => [ :sid, :cid ], :child_key => [ :sid, :cid ], :required => true

  property :sid, Integer, :key => true, :index => true
  
  property :cid, Integer, :key => true, :index => true
  
  property :udp_sport, Integer, :index => true
  
  property :udp_dport, Integer, :index => true

  property :udp_len, Integer, :lazy => true
  
  property :udp_csum, Integer, :lazy => true

end
