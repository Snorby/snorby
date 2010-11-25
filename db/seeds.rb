# Define the snort schema version
SnortSchema.create(:vseq => 107, :ctime => Time.now, :version => "Snorby #{Snorby::VERSION}") if SnortSchema.first.blank?

# Default user setup
User.create(:name => 'Administrator', :email => 'snorby@snorby.org', :password => 'snorby', :password_confirmation => 'snorby', :admin => true) if User.all.blank?

# Snorby General Settings
settings = %w(organization daily weekly monthly lookups notes logo)

settings.each do |name|
  Setting.set(name.to_sym, '') unless Setting.find(name.to_sym)
end

# Load Default Classifications

Classification.first_or_create({ :name => "Unauthorized Root Access" }, {
  :name => 'Unauthorized Root Access',
  :description => 'Unauthorized Root Access',
  :hotkey => 1,
  :locked => true
})

Classification.first_or_create({ :name => "Unauthorized User Access" }, {
  :name => 'Unauthorized User Access',
  :description => 'Unauthorized User Access',
  :hotkey => 2,
  :locked => true
})

Classification.first_or_create({ :name => "Attempted Unauthorized Access" }, {
  :name => 'Attempted Unauthorized Access',
  :description => 'Attempted Unauthorized Access',
  :hotkey => 3,
  :locked => true
})

Classification.first_or_create({ :name => "Denial of Service Attack" }, {
  :name => 'Denial of Service Attack',
  :description => 'Denial of Service Attack',
  :hotkey => 4,
  :locked => true
})

Classification.first_or_create({ :name => "Policy Violation" }, {
  :name => 'Policy Violation',
  :description => 'Policy Violation',
  :hotkey => 5,
  :locked => true
})

Classification.first_or_create({:name => "Reconnaissance"}, {
  :name => 'Reconnaissance',
  :description => 'Reconnaissance',
  :hotkey => 6,
  :locked => true
})

Classification.first_or_create({:name => "Virus Infection"}, {
  :name => 'Virus Infection',
  :description => 'Virus Infection',
  :hotkey => 7,
  :locked => true
})

Classification.first_or_create({:name => "False Positive"}, {
  :name => 'False Positive',
  :description => 'False Positive',
  :hotkey => 8,
  :locked => true
})

# Load Default Severities
if Severity.all.blank?
  Severity.create(:id => 1, :sig_id => 1, :name => 'High Severity', :text_color => "#ffffff", :bg_color => "#ff0000")
  Severity.create(:id => 2, :sig_id => 2, :name => 'Medium Severity', :text_color => "#ffffff", :bg_color => "#fab908")
  Severity.create(:id => 3, :sig_id => 3, :name => 'Low Severity', :text_color => "#ffffff", :bg_color => "#3a781a")
end
