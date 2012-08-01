require 'snorby/model/counter'

class User
  
  include DataMapper::Resource
  include DataMapper::Validate
  # include Paperclip::Resource
  include Snorby::Model::Counter

  cattr_accessor :current_user

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  if Snorby::CONFIG[:authentication_mode] == "cas"
    devise :cas_authenticatable, :registerable, :trackable
    property :email, String, :required => true, :unique => true 
  else
    devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable
  end

  attr_accessor :crop_x, :crop_y, :crop_w, :crop_h

  property :favorites_count, Integer, :index => true, :default => 0
  
  property :accept_notes, Integer, :default => 1
  
  property :notes_count, Integer, :index => true, :default => 0
  
  # Primary key of the user
  property :id, Serial, :key => true, :index => true
  
  # Email of the user
  # 
  # property :email, String, :required => true, :unique => true
  #
  # property :avatar_file_name, String
  # 
  # property :avatar_content_type, String
  # 
  # property :avatar_file_size, Integer
  # 
  # property :avatar_updated_at, DateTime
  
  property :per_page_count, Integer, :index => true, :default => 25
  
  # Full name of the user
  property :name, String, :lazy => true, :lazy => true
  
  # The timezone the user lives in
  property :timezone, String, :default => 'UTC', :lazy => true
  
  # Define if the user has administrative privileges
  property :admin, Boolean, :default => false
  
  # Define if the user has been enabled/disabled
  property :enabled, Boolean, :default => true

  # Define if get avatar from gravatar.com or not
  property :gravatar, Boolean, :default => false
  
  # Define created_at and updated_at timestamps
  timestamps :at

  property :avatar, String, :default => false
  # has_attached_file :avatar,
  # :styles => {
    # :large => "500x500>",
    # :medium => "300x300>",
    # :small => "100x100#"
  # }, :default_url => '/images/default_avatar.png', :processors => [:cropper],
    # :whiny => false

  # validates_attachment_content_type :avatar, :content_type => ['image/jpeg', 'image/gif', 'image/png', 'image/pjpeg', 'image/x-png'], 
  # :message => 'Uploaded file is not an image', 
  # :if => Proc.new { |profile| profile.avatar.file? }

  has n, :notifications, :constraint => :destroy

  has n, :favorites, :child_key => :user_id, :constraint => :destroy

  has n, :notes, :child_key => :user_id, :constraint => :destroy

  has n, :saved_searches, :child_key => :user_id, :constraint => :destroy

  has n, :events

  has n, :events, :through => :favorites

  #
  # Converts the user to a String.
  #
  # @return [String]
  #   The name of the user.
  #
  def to_s
    self.name.to_s
  end

  def classify_count
    Event.count(:user_id => self.id.to_i) 
  end

  def accepts_note_notifications?(event=false)
    if accept_notes == 1
      return true
    elsif accept_notes == 3
      return false unless event
      return true if added_notes_for_event?(event)
      return false
    else
      return false
    end
  end
  
  def added_notes_for_event?(event)
    return true if event.notes.map(&:user_id).include?(id)
    false
  end

  def cropping?
    !crop_x.blank? && !crop_y.blank? && !crop_w.blank? && !crop_h.blank?
  end

  def avatar_geometry(style = :original)
    @geometry ||= {}
    @geometry[style] ||= Paperclip::Geometry.from_file(avatar.path(style))
  end

  def reprocess_avatar
    avatar.reprocess! if cropping?
  end

end
