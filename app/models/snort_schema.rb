class SnortSchema

  include DataMapper::Resource

  storage_names[:default] = "schema"
  
  property :id, Serial, :key => true, :index => true, :min => 0

  property :vseq, Integer, :min => 0

  property :ctime, ZonedTime

  property :version, String
  
end
