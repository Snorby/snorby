class Classification

  include DataMapper::Resource

  property :id, Serial, :index => true

  property :name, String

  property :description, Text

  property :hotkey, Integer, :index => true

  property :events_counter, Integer, :default => 0, :index => true

  property :locked, Boolean, :default => false, :index => true

  has n, :events, :constraint => :destroy

  validates_uniqueness_of :hotkey

  def shortcut
    "f#{hotkey}"
  end

end
