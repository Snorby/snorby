class SigReference

  include DataMapper::Resource

  storage_names[:default] = "sig_reference"

  property :sig_id, Integer, :key => true

  property :ref_seq, Integer, :key => true
  
  property :ref_id, Integer

end
