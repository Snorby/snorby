require 'snorby/model/counter'

class Favorite
  
  include DataMapper::Resource
  include Snorby::Model::Counter

  belongs_to :user
  
  belongs_to :event, :child_key => [ :sid, :cid ]

  property :id, Serial, :index => true

  property :sid, Integer, :index => true
  
  property :cid, Integer, :index => true
  
  property :user_id, Integer, :index => true

  after :create do
    self.event.up(:users_count) if self.event
    self.user.up(:favorites_count) if self.user
  end
  
  before :destroy! do
    puts 'in favorite down'
    self.event.down(:users_count) if self.event
    self.user.down(:favorites_count) if self.user
  end

end
