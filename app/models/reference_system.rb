class ReferenceSystem

  include DataMapper::Resource

  storage_names[:default] = "reference_system"

  property :ref_system_id, Serial, :key => true, :index => true

  property :ref_system_name, String

end
