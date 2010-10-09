class Tcp

  include DataMapper::Resource

  storage_names[:default] = "tcphdr"
  
  belongs_to :sensor, :parent_key => [ :sid ], :child_key => [ :sid ], :required => true
  
  belongs_to :event, :parent_key => [ :sid, :cid ], :child_key => [ :sid, :cid ], :required => true

  property :sid, Integer, :key => true
  
  property :cid, Integer, :key => true
  
  property :tcp_sport, Integer
  
  property :tcp_dport, Integer

  property :tcp_seq, Integer
  
  property :tcp_ack, Integer
  
  property :tcp_off, Integer
  
  property :tcp_res, Integer
  
  property :tcp_flags, Integer
  
  property :tcp_win, Integer
  
  property :tcp_csum, Integer
  
  property :tcp_urp, Integer

end
