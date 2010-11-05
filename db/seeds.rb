# Define the snort schema version
SnortSchema.create(:vseq => 107, :ctime => Time.now, :version => "Snorby #{Snorby::VERSION}") if SnortSchema.first.blank?

# Default user setup
User.create(:name => 'Administrator', :password => 'snorby', :password_confirmation => 'snorby', :email => 'snorby@snorby.org', :admin => true) if User.all.blank?

# Load Classifications
if Classification.all.blank?
  Classification.create(:id => 1, :name => 'False Positive', :description => "", :hotkey => 1)
  Classification.create(:id => 2, :name => 'Unauthorized Access', :description => "", :hotkey => 2)
  Classification.create(:id => 3, :name => 'Malicious Software', :description => "", :hotkey => 3)
  Classification.create(:id => 4, :name => 'Denial Of Service', :description => "", :hotkey => 4)
  Classification.create(:id => 5, :name => 'Reconnoissance', :description => "", :hotkey => 5)
  Classification.create(:id => 6, :name => 'Policy Violation', :description => "", :hotkey => 6)
end

# Load Default Severities
if Severity.all.blank?
  Severity.create(:id => 1, :sig_id => 1, :name => 'High Severity', :text_color => "#ffffff", :bg_color => "#ff0000")
  Severity.create(:id => 2, :sig_id => 2, :name => 'Medium Severity', :text_color => "#ffffff", :bg_color => "#fab908")
  Severity.create(:id => 3, :sig_id => 3, :name => 'Low Severity', :text_color => "#ffffff", :bg_color => "#bd52bd")
end
