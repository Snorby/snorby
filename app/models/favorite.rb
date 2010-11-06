class Favorite

  include DataMapper::Resource

  is :counter_cacheable

  belongs_to :user
  
  counter_cacheable :user, :counter_property => :favorites_count
  
  belongs_to :event, :child_key => [ :sid, :cid ]

  property :id, Serial, :index => true

  property :sid, Integer, :index => true
  
  property :cid, Integer, :index => true
  
  property :user_id, Integer, :index => true

end
