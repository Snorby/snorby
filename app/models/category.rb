class Category
  include DataMapper::Resource

  # Maps to the Snort sig_class table
  # 
  # Changed the name to category to extend the functionality
  # and meaning of the below attributes.
  # 
  storage_names[:default] = "sig_class"
  
  #
  # Signature Class ID
  # 
  property :sig_class_id, Serial, :key => true, :index => true, :min => 0
  
  #
  # Signature Class Name
  # 
  # This property will be used to hold new and
  # existing event categories. 
  # 
  property :sig_class_name, String

end
