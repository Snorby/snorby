class Opt

  include DataMapper::Resource

  storage_names[:default] = "opt"

  belongs_to :sensor, :parent_key => [ :sid ], :child_key => [ :sid ], :required => true

  belongs_to :event, :parent_key => [ :sid, :cid ], :child_key => [ :sid, :cid ], :required => true

  property :sid, Integer, :key => true, :index => true, :min => 0
  
  property :cid, Integer, :key => true, :index => true, :min => 0

  property :optid, Integer, :key => true, :index => true, :min => 0
  
  property :opt_proto, Integer, :lazy => true, :min => 0
  
  property :opt_code, Integer, :lazy => true, :min => 0
  
  property :opt_len, Integer, :lazy => true, :min => 0
  
  property :opt_data, Text


end
