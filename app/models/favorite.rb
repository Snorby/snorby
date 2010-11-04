require 'dm-is-counter_cacheable'

class Favorite

  include DataMapper::Resource

  is :counter_cacheable

  belongs_to :user, :child_key => :user_id
  
  counter_cacheable :user
  
  belongs_to :event, :child_key => [ :sid, :cid ]

  property :id, Serial, :index => true

  property :sid, Integer, :index => true
  
  property :cid, Integer, :index => true
  
  property :user_id, Integer, :index => true

end
