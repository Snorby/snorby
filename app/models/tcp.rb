class Tcp

  include DataMapper::Resource

  storage_names[:default] = "tcphdr"
  
  belongs_to :sensor, :parent_key => [ :sid ], :child_key => [ :sid ], :required => true
  
  belongs_to :event, 
             :parent_key => [ :sid, :cid ], 
             :child_key => [ :sid, :cid ], 
             :required => true

  property :sid, Integer, :key => true, :index => true
  
  property :cid, Integer, :key => true, :index => true
  
  property :tcp_sport, Integer, :index => true
  
  property :tcp_dport, Integer, :index => true

  property :tcp_seq, Integer, :lazy => true
  
  property :tcp_ack, Integer, :lazy => true
  
  property :tcp_off, Integer, :lazy => true
  
  property :tcp_res, Integer, :lazy => true
  
  property :tcp_flags, Integer, :lazy => true
  
  property :tcp_win, Integer, :lazy => true
  
  property :tcp_csum, Integer, :lazy => true
  
  property :tcp_urp, Integer, :lazy => true

end
