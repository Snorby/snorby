class DailyCache

  include DataMapper::Resource

  property :id, Serial
  
  property :timestamp, DateTime
  
  property :event_count, Integer, :default => 0
  
  property :tcp_count, Integer, :default => 0
  
  property :udp_count, Integer, :default => 0
  
  property :icmp_count, Integer, :default => 0
  
  property :src_metrics, Object
  
  property :dst_metrics, Object
  
  property :port_metrics, Object
  
  property :sensor_metrics, Object
  
  property :severity_metrics, Object

end
