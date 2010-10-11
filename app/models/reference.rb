class Reference

  include DataMapper::Resource

  storage_names[:default] = "reference"

  property :ref_id, Serial, :key => true, :index => true
  
  property :ref_system_id, Integer

  property :ref_tag, Text


end
