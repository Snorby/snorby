class Icmp

  include DataMapper::Resource

  storage_names[:default] = "icmphdr"

  belongs_to :sensor, :parent_key => :sid, :child_key => :sid, :required => true

  belongs_to :event, :parent_key => [:sid, :cid], :child_key => [:sid, :cid], :required => true

  property :sid, Integer, :key => true, :index => true
  
  property :cid, Integer, :key => true, :index => true

  property :icmp_type, Integer
  
  property :icmp_code, Integer
  
  property :icmp_csum, Integer
  
  property :icmp_id, Integer
  
  property :icmp_seq, Integer

end
