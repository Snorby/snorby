class Favorite

  include DataMapper::Resource

  belongs_to :user
  
  belongs_to :event, :child_key => [ :sid, :cid ]

  property :id, Serial, :index => true

  property :sid, Integer, :index => true
  
  property :cid, Integer, :index => true
  
  property :user_id, Integer, :index => true


  after :create do
    event = self.event
    user = self.user
    event.update(:users_count => event.users_count + 1)
    user.update(:favorites_count => user.favorites_count + 1)
  end
  
  before :destroy do
    event = self.event
    user = self.user
    event.update(:users_count => event.users_count - 1)
    user.update(:favorites_count => user.favorites_count - 1)
  end

end
