class SigReference

  include DataMapper::Resource

  storage_names[:default] = "sig_reference"

  property :sig_id, Integer, :key => true, :index => true

  property :ref_seq, Integer, :key => true, :index => true
  
  property :ref_id, Integer

  has 1, :reference, :parent_key => :ref_id, :child_key => [ :ref_id ]

end
