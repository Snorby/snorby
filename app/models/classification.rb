class Classification

  include DataMapper::Resource

  property :id, Serial

  property :name, String
  
  property :description, Text
  
  property :hotkey, Integer
  
  has n, :events, :constraint => :destroy

  validates_uniqueness_of :hotkey

  def shortcut
    "F#{hotkey}"
  end

end
