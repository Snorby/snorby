require 'snorby/model'

class Ip
  
  include Snorby::Model
  include DataMapper::Resource

  storage_names[:default] = "iphdr"

  belongs_to :sensor, :parent_key => [ :sid ], :child_key => [ :sid ], :required => true

  belongs_to :event, :parent_key => [ :sid, :cid ], :child_key => [ :sid, :cid ], :required => true

  property :sid, Integer, :key => true
  
  property :cid, Integer, :key => true

  property :ip_src, NumericIPAddr
  
  property :ip_dst, NumericIPAddr
  
  property :ip_ver, Integer
  
  property :ip_hlen, Integer
  
  property :ip_tos, Integer
  
  property :ip_len, Integer
  
  property :ip_id, Integer
  
  property :ip_flags, Integer
  
  property :ip_off, Integer
  
  property :ip_ttl, Integer
  
  property :ip_proto, Integer
  
  property :ip_csum, Integer

end
