class Note

  belongs_to :user
  
  belongs_to :sensor, :required => true
  
  belongs_to :event, :required => true
  
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
