class SnortSchema

  include DataMapper::Resource

  storage_names[:default] = "schema"
  
  property :id, Serial

  property :vseq, Integer

  property :ctime, DateTime

  property :version, String
  
end
