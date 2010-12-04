require 'snorby/model'

class Notification
  include Snorby::Model
  include DataMapper::Validate
  include DataMapper::Resource

  property :id, Serial
  
  property :description, Text
  
  property :sig_id, Integer
  
  property :ip_src, NumericIPAddr, :index => true, :min => 0, :required => true, :default => 0
  
  property :ip_dst, NumericIPAddr, :index => true, :min => 0, :required => true, :default => 0
  
  property :user_id, Integer
  
  property :user_ids, Object
  
  property :sensor_ids, Object

  # Define created_at and updated_at timestamps
  timestamps :at

end
