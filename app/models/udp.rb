class Udp

  include DataMapper::Resource

  storage_names[:default] = "udphdr"

  belongs_to :sensor, :parent_key => [ :sid ], :child_key => [ :sid ], :required => true
  
  belongs_to :event, :parent_key => [ :sid, :cid ], :child_key => [ :sid, :cid ], :required => true

  property :sid, Integer, :key => true, :index => true, :min => 0
  
  property :cid, Integer, :key => true, :index => true, :min => 0
  
  property :udp_sport, Integer, :index => true, :min => 0
  
  property :udp_dport, Integer, :index => true, :min => 0

  property :udp_len, Integer, :lazy => true, :min => 0
  
  property :udp_csum, Integer, :lazy => true, :min => 0

end
