require 'snorby/model/counter'
class User
  
  include DataMapper::Resource
  include DataMapper::Validate
  # include Paperclip::Resource
  include Snorby::Model::Counter
  # include Rails.application.routes.url_helpers
  
  # include Rails.application.routes.url_helpers

  cattr_accessor :current_user, :snorby_url, :current_json

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
  
  property :per_page_count, Integer, :index => true, :default => 45
  
  # Full name of the user
  property :name, String, :lazy => true
  
  # The timezone the user lives in
  property :timezone, String, :default => 'UTC', :lazy => true
  
  # Define if the user has administrative privileges
  property :admin, Boolean, :default => false
  
  # Define if the user has been enabled/disabled
  property :enabled, Boolean, :default => true

  # Define if get avatar from gravatar.com or not
  property :gravatar, Boolean, :default => true
  
  # Define created_at and updated_at timestamps
  timestamps :at
  property :created_at, ZonedTime
  property :updated_at, ZonedTime
  property :last_sign_in_at, ZonedTime

  # for sure with socket.io sessions
  property :online, Boolean, :default => false

  # property :avatar, Text, :default => false
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

  property :last_daily_report_at, ZonedTime, :default => Time.zone.now
  property :last_weekly_report_at, Integer, :default => Time.zone.now.strftime("%Y%W")
  property :last_monthly_report_at, Integer, :default => Time.zone.now.strftime("%Y%m")

  property :last_email_report_at, ZonedTime
  property :email_reports, Boolean, :default => false

  property :daily_reports, Boolean, :default => false
  property :weekly_reports, Boolean, :default => false
  property :monthly_reports, Boolean, :default => false

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

  def avatar
    default_url = File.join(::User.snorby_url, "#{Snorby::CONFIG[:baseuri]}/images/default_avatar.png")
    return default_url unless self.gravatar

    email_address = self.email.downcase

    # create the md5 hash
    hash = Digest::MD5.hexdigest(email_address)
    "https://gravatar.com/avatar/#{hash}.png?s=256&d=#{CGI.escape(default_url)}"
  end

  def in_json
    # create the md5 hash
    hash = Digest::MD5.hexdigest(self.email)
    #"https://gravatar.com/avatar/#{hash}.png?s=256&d=#{CGI.escape(default_url)}"
    data = self.attributes
    data[:gravatar_hash] = hash
    data[:classify_count] = classify_count
    data
  end

  def classify_count
    Event.count(:user_id => self.id.to_i) 
  end

  def send_daily_report(start_time, end_time)
    ReportMailer.daily_report("#{name} <#{email}>", timezone).deliver
  end

  def send_weekly_report
    ReportMailer.weekly_report("#{name} <#{email}>", timezone).deliver
  end

  def send_monthly_report
    ReportMailer.monthly_report("#{name} <#{email}>", timezone).deliver
  end

  def send_update_report(data)
    ReportMailer.update_report("#{name} <#{email}>", data, timezone).deliver
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
