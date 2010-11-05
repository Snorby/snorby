class Classification

  include DataMapper::Resource

  is :predefined

  property :id, Serial, :index => true

  property :name, String

  property :description, Text

  property :hotkey, Integer, :index => true

  property :events_counter, Integer, :default => 0, :index => true

  has n, :events, :constraint => :destroy

  validates_uniqueness_of :hotkey

  predefine :unauthorized_root_access,
    :name => 'Unauthorized Root Access',
    :description => '',
    :hotkey => 1

  predefine :unauthorized_user_access,
    :name => 'Unauthorized User Access',
    :description => '',
    :hotkey => 2

  predefine :attempted_unauthorized_access,
    :name => 'Attempted Unauthorized Access',
    :description => '',
    :hotkey => 3

  predefine :denial_of_service_attack,
    :name => 'Denial of Service Attack',
    :description => '',
    :hotkey => 4

  predefine :policy_violation,
    :name => 'Policy Violation',
    :description => '',
    :hotkey => 5

  predefine :reconnaissance,
    :name => 'Reconnaissance',
    :description => '',
    :hotkey => 6

  predefine :virus_infection,
    :name => 'Virus Infection',
    :description => '',
    :hotkey => 7

  predefine :false_positive,
    :name => 'False Positive',
    :description => '',
    :hotkey => 8

  def shortcut
    "f#{hotkey}"
  end

end
