class ReferenceSystem

  include DataMapper::Resource

  storage_names[:default] = "reference_system"

  property :ref_system_id, Serial, :key => true, :index => true, :min => 0

  property :ref_system_name, String

  has n, :references, :parent_key => :ref_system_id, :child_key => [ :ref_system_id ]

end
