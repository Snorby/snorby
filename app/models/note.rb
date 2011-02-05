class Note

  belongs_to :user
  
  belongs_to :sensor
  
  belongs_to :event

  validates_presence_of :sensor
  validates_presence_of :event
  
  validates_presence_of :body

  after :create do
    event = self.event
    user = self.user
    event.update(:notes_count => event.notes_count + 1)
    user.update(:notes_count => user.notes_count + 1)
  end
  
  before :destroy do
    event = self.event
    user = self.user
    event.update(:notes_count => event.notes_count - 1) if event
    user.update(:notes_count => user.notes_count - 1) if user
  end

  def html_id
    "note_#{id}"
  end

end
