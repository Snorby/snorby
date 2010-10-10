require 'snorby/model'

class User
  include Snorby::Model
  include DataMapper::Resource
  
  cattr_accessor :current_user
  
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable

  # Primary key of the user
  property :id, Serial

  # Email of the user
  property :email, String, :required => true, :unique => true

  # Full name of the user
  property :name, String

  # The timezone the user lives in
  property :timezone, String, :default => 'UTC'
  
  # Define if the user has administrative privileges
  property :admin, Boolean, :default => false

  # Define created_at and updated_at timestamps
  timestamps :at

  #
  # Converts the user to a String.
  #
  # @return [String]
  #   The name of the user.
  #
  def to_s
    self.name.to_s
  end

end
