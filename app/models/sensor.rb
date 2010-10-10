class Sensor

  include DataMapper::Resource

  storage_names[:default] = "sensor"

  has n, :events, :child_key => :sid

  property :sid, Serial, :index => true

  property :name, String, :default => 'Click To Change Me'

  property :hostname, Text, :index => true

  property :interface, Text
  
  property :filter, Text

  property :detail, Integer
  
  property :encoding, Integer
  
  property :last_cid, Integer

end
