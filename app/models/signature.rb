class Signature

  include DataMapper::Resource

  storage_names[:default] = "signature"

  #belongs_to :category, :parent_key => :sig_class_id, :child_key => :sig_class_id, :required => true

  has n, :events, :parent_key => :sig_id, :child_key => :sig_id
  
  belongs_to :severity, :child_key => :sig_priority, :parent_key => :sig_id
  
  #has n, :sig_references, :parent_key => :sig_rev, :child_key => [ :ref_seq ]

  property :sig_id, Serial, :key => true, :index => true

  property :sig_class_id, Integer, :index => true

  property :sig_name, Text
  
  property :sig_priority, Integer, :index => true
    
  property :sig_rev, Integer, :lazy => true
      
  property :sig_sid, Integer, :lazy => true

  property :sig_gid, Integer, :lazy => true

  def severity_id
    sig_priority
  end
  
  def name
    sig_name
  end

end
