class Sensor

  include DataMapper::Resource

  storage_names[:default] = "sensor"

  has n, :events, :child_key => :sid

  property :sid, Serial, :key => true, :index => true

  property :name, String, :default => 'Click To Change Me'

  property :hostname, Text, :index => true

  property :interface, Text
  
  property :filter, Text

  property :detail, Integer, :index => true
  
  property :encoding, Integer, :index => true
  
  property :last_cid, Integer, :index => true

end
