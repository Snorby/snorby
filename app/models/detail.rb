class Detail
  include DataMapper::Resource
  
  storage_names[:default] = "detail"

  property :detail_type, Serial, :key => true, :index => true
  
  property :detail_text, Text

end
