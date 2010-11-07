class Cache

  include DataMapper::Resource

  has 1, :event, :parent_key => [ :sid, :cid ], :child_key => [ :sid, :cid ]

  property :id, Serial

  property :sid, Integer
  
  property :cid, Integer

  property :ran_at, DateTime
  
  property :event_count, Integer, :default => 0
  
  property :tcp_count, Integer, :default => 0
  
  property :udp_count, Integer, :default => 0
  
  property :icmp_count, Integer, :default => 0
  
  property :total_src, Integer, :default => 0
  
  property :total_dst, Integer, :default => 0
  
  property :uniq_src, Integer, :default => 0
  
  property :uniq_dst, Integer, :default => 0
  
  property :sensor_metrics, Object
  
  property :port_metrics, Object
  
  property :classification_metrics, Object
  
  property :severity_metrics, Object

end
