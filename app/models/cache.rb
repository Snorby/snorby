class Cache

  include DataMapper::Resource

  property :id, Serial

  property :sid, Integer
  
  property :cid, Integer

  property :ran_at, DateTime
  
  property :event_count, Integer
  
  property :tcp_count, Integer
  
  property :udp_count, Integer
  
  property :icmp_count, Integer
  
  property :total_src, Integer
  
  property :total_dst, Integer
  
  property :uniq_src, Integer
  
  property :uniq_dst, Integer
  
  property :port_metrics, Object
  
  property :classification_metrics, Object
  
  property :severity_metrics, Object

end
