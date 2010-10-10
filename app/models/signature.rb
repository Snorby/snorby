class Signature

  include DataMapper::Resource

  storage_names[:default] = "signature"

  #belongs_to :category, :parent_key => :sig_class_id, :child_key => :sig_class_id, :required => true

  has n, :events, :parent_key => :sig_id, :child_key => :sig_id
  
  #has n, :sig_references, :parent_key => :sig_rev, :child_key => [ :ref_seq ]

  property :sig_id, Serial, :key => true, :index => true

  property :sig_class_id, Integer

  property :sig_name, Text
  
  property :sig_priority, Integer
    
  property :sig_rev, Integer
      
  property :sig_sid, Integer

  property :sig_gid, Integer

  def severity
    sig_priority
  end
  
  def name
    sig_name
  end

end
