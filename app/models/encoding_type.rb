class EncodingType
  include DataMapper::Resource

  storage_names[:default] = "encoding"

  property :encoding_type, Serial, :key => true, :index => true, :min => 0

  property :encoding_text, Text

end
