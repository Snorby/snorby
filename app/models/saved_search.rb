require "digest"

class SavedSearch

  include DataMapper::Resource

  storage_names[:default] = "search"

  property :id, Serial, :key => true
  
  property :user_id, Integer, :index => true

  property :rule_count, Integer, :index => true, :default => 0

  property :public, Boolean, :index => true, :default => false

  property :title, String

  property :search, Object, :lazy => true

  property :checksum, Text

  # timestamps :at
  property :created_at, ZonedTime
  property :updated_at, ZonedTime
  
  belongs_to :user

  validates_presence_of :search, :user_id, :title, :checksum

  validates_uniqueness_of :checksum

  before :valid?, :set_checksum

  before :create do
    set_checksum
  end

  before :update do
    set_checksum
  end

  def set_checksum(context = :default)
    self.checksum = Digest::SHA2.hexdigest("#{self.user_id}#{self.search}")
  end

end

