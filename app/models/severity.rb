require 'snorby/model'

class Severity
  
  include Snorby::Model
  include DataMapper::Resource

  has n, :signatures, :child_key => :sig_priority, :parent_key => :sig_id

  property :id, Serial, :index => true, :key => true
  
  property :sig_id, Integer, :index => true, :key => true
  
  # Set the name of the severity
  property :name, String

  # Set the severity text color
  property :text_color, String, :default => '#fff', :index => true
  
  # Set the severity background color
  property :bg_color, String, :default => '#ddd', :index => true

end
