class ReferenceSystem

  include DataMapper::Resource

  storage_names[:default] = "reference_system"

  property :ref_system_id, Serial

  property :ref_system_name, String

end
