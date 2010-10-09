class Opt

  include DataMapper::Resource

  storage_names[:default] = "opt"

  belongs_to :sensor, :parent_key => [ :sid ], :child_key => [ :sid ], :required => true

  belongs_to :event, :parent_key => [ :sid, :cid ], :child_key => [ :sid, :cid ], :required => true

  property :sid, Integer, :key => true
  
  property :cid, Integer, :key => true

  property :optid, Integer, :key => true
  
  property :opt_proto, Integer
  
  property :opt_code, Integer
  
  property :opt_len, Integer
  
  property :opt_data, Text


end
