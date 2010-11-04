class Classification

  include DataMapper::Resource

  property :id, Serial, :index => true

  property :name, String
  
  property :description, Text
  
  property :hotkey, Integer, :index => true
  
  property :events_counter, Integer, :default => 0, :index => true
  
  has n, :events, :constraint => :destroy

  validates_uniqueness_of :hotkey

  def shortcut
    "f#{hotkey}"
  end

end
