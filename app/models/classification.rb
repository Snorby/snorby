class Classification

  include DataMapper::Resource

  property :id, Serial

  property :name, String
  
  property :description, Text
  
  has n, :events, :constraint => :destroy

end
