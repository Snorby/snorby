require 'snorby/model'

class Ip
  include Snorby::Model
  include DataMapper::Resource

  storage_names[:default] = "iphdr"

  property :sid, Integer, :key => true, :index => true
  
  property :cid, Integer, :key => true, :index => true

  property :ip_src, NumericIPAddr, :index => true
  
  property :ip_dst, NumericIPAddr, :index => true
  
  property :ip_ver, Integer, :lazy => true
  
  property :ip_hlen, Integer, :lazy => true
  
  property :ip_tos, Integer, :lazy => true
  
  property :ip_len, Integer, :lazy => true
  
  property :ip_id, Integer, :lazy => true
  
  property :ip_flags, Integer, :lazy => true
  
  property :ip_off, Integer, :lazy => true
  
  property :ip_ttl, Integer, :lazy => true
  
  property :ip_proto, Integer, :lazy => true
  
  property :ip_csum, Integer, :lazy => true
  
  belongs_to :sensor, :parent_key => [ :sid ], :child_key => [ :sid ], :required => true

  has n, :events, :parent_key => [ :sid, :cid ], :child_key => [ :sid, :cid ], :constraint => :destroy

end
