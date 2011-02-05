require 'snorby/model/counter'

class User < ActiveRecord::Base
  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
  include Snorby::Model::Counter

  cattr_accessor :current_user
  attr_accessor :crop_x, :crop_y, :crop_w, :crop_h

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable

  has_attached_file :avatar,
  :styles => {
    :large => "500x500>",
    :medium => "300x300>",
    :small => "100x100#"
  }, :default_url => '/images/default_avatar.png', :processors => [:cropper]

  validates_attachment_content_type :avatar, :content_type => ["image/png", "image/gif", "image/jpeg"]

  has_many :notifications, :dependent => :destroy

  has_many :favorites, :dependent => :destroy

  has_many :events, :through => :favorites

  has_many :notes, :dependent => :destroy

  has_many :events

  #
  # Converts the user to a String.
  #
  # @return [String]
  #   The name of the user.
  #
  def to_s
    self.name.to_s
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
