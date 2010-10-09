class Sensor

  include DataMapper::Resource

  storage_names[:default] = "sensor"

  has n, :events, :child_key => [ :sid ]

  property :sid, Serial

  property :hostname, Text

  property :interface, Text
  
  property :filter, Text

  property :detail, Integer
  
  property :encoding, Integer
  
  property :last_cid, Integer

end
