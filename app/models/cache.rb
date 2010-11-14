class Cache

  include DataMapper::Resource

  property :id, Serial

  property :sid, Integer
  
  property :cid, Integer

  property :ran_at, DateTime
  
  property :event_count, Integer, :default => 0
  
  property :tcp_count, Integer, :default => 0
  
  property :udp_count, Integer, :default => 0
  
  property :icmp_count, Integer, :default => 0
  
  property :classification_metrics, Object
  
  property :severity_metrics, Object
  
  property :signature_metrics, Object

  belongs_to :sensor, :parent_key => :sid, :child_key => :sid
  
  has 1, :event, :parent_key => [ :sid, :cid ], :child_key => [ :sid, :cid ]

end
