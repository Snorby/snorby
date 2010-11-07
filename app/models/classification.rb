class Classification

  include DataMapper::Resource

  property :id, Serial, :index => true

  property :name, String

  property :description, Text

  property :hotkey, Integer, :index => true

  property :locked, Boolean, :default => false, :index => true

  property :events_count, Integer, :index => true, :default => 0

  has n, :events, :constraint => :destroy

  validates_uniqueness_of :hotkey

  def shortcut
    "f#{hotkey}"
  end
  
  def up_counter(column)
    if self.respond_to?(column.to_sym)
      count = self.send(column.to_sym).to_i + 1
      self.update(column.to_sym => count)
    end
  end
  
  def down_counter(column)
    if self.respond_to?(column.to_sym)
      count = self.send(column.to_sym).to_i - 1
      self.update(column.to_sym => count)
    end
  end

  def event_percentage
    begin
      if Cache.all.blank? &&
        if self.events_count == 0
          0
        else
          ((self.events_count.to_f / Event.count.to_f) * 100).round(2)
        end
      else
        ((self.events_count.to_f / Cache.last.event_count.to_f) * 100).round(2)
      end
    rescue FloatDomainError
      0
    end
  end

end
