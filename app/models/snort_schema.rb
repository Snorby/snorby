class SnortSchema

  include DataMapper::Resource

  storage_names[:default] = "schema"
  
  property :id, Serial, :key => true, :index => true

  property :vseq, Integer

  property :ctime, DateTime

  property :version, String
  
end
