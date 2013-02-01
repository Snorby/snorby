require 'snorby/model'

class Severity
  
  include Snorby::Model
  include DataMapper::Validate
  include DataMapper::Resource

  has n, :signatures, :child_key => :sig_priority, :parent_key => :sig_id

  property :id, Serial, :index => true, :key => true, :min => 0
  
  property :sig_id, Integer, :index => true, :min => 0
  
  property :events_count, Integer, :index => true, :default => 0, :min => 0
  
  # Set the name of the severity
  property :name, String

  # Set the severity text color
  property :text_color, String, :default => '#ffffff', :index => true
  
  # Set the severity background color
  property :bg_color, String, :default => '#dddddd', :index => true

  validates_presence_of :sig_id, :name, :text_color
  validates_uniqueness_of :sig_id
  validates_format_of :text_color, :with => /^#?([a-f]|[A-F]|[0-9]){3}(([a-f]|[A-F]|[0-9]){3})?$/, :message => "is invalid"
  validates_format_of :bg_color, :with => /^#?([a-f]|[A-F]|[0-9]){3}(([a-f]|[A-F]|[0-9]){3})?$/, :message => "is invalid"

  def locked?
    return true if [1,2,3].include?(id)
    false
  end

end
