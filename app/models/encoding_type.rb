class EncodingType

  include DataMapper::Resource

  storage_names[:default] = "encoding"

  property :encoding_type, Serial

  property :encoding_text, Text

end
