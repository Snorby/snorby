class Signature

  include DataMapper::Resource

  storage_names[:default] = "signature"

  belongs_to :category, :parent_key => [ :sig_class_id ], :child_key => [ :sig_class_id ], :required => true

  has n, :sig_references, :child_key => [ :sig_id ]

  property :sig_id, Serial

  property :sig_name, Text
  
  property :sig_class_id, Integer, :key => true
  
  property :sig_priority, Integer
    
  property :sig_rev, Integer
      
  property :sig_sid, Integer

  property :sig_gid, Integer

end
