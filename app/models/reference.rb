class Reference

  include DataMapper::Resource

  storage_names[:default] = "reference"

  property :ref_id, Serial, :key => true, :index => true, :min => 0
  
  property :ref_system_id, Integer, :min => 0

  property :ref_tag, Text

  belongs_to :sig_reference, :parent_key => :ref_id, :child_key => [ :ref_id ]

  belongs_to :reference_system, :parent_key => :ref_system_id, :child_key => [ :ref_system_id ]

  def value
    ref_tag
  end

  def type
   reference_system.present? ? reference_system.ref_system_name : 'N/A'
  end

end
