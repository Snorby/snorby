class Favorite

  include DataMapper::Resource

  include DataMapper::CounterCacheable

  belongs_to :user, :child_key => :user_id, :counter_cache => true
  
  belongs_to :event, :child_key => [ :sid, :cid ]

  property :id, Serial, :index => true

  property :sid, Integer, :index => true
  
  property :cid, Integer, :index => true
  
  property :user_id, Integer, :index => true

end
