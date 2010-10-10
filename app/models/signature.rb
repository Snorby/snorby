class Signature

  include DataMapper::Resource

  storage_names[:default] = "signature"

  belongs_to :category, :parent_key => :sig_class_id, :child_key => :sig_class_id, :required => true

  has n, :events, 'Event', :parent_key => :sig_id, :child_key => :signature
  
  #has n, :sig_references, :parent_key => :sig_rev, :child_key => [ :ref_seq ]

  property :sig_id, Serial, :key => true

  property :sig_class_id, Integer, :key => true

  property :sig_name, Text
  
  property :sig_priority, Integer
    
  property :sig_rev, Integer
      
  property :sig_sid, Integer

  property :sig_gid, Integer

end
