namespace :snorby do
  
  desc 'Setup'
  task :setup => :environment do
    # Create the snorby database if it does not currently exist
    Rake::Task['db:create'].invoke
    # Setup the snorby database
    Rake::Task['db:autoupgrade'].invoke
    # Define the snort schema version
    SnortSchema.create(:vseq => 107, :ctime => Time.now, :version => "Snorby #{Snorby::VERSION}") if SnortSchema.first.blank?
    # Default user setup
    User.create(:name => 'Administrator', :password => 'snorby', :password_confirmation => 'snorby', :email => 'snorby@snorby.com', :admin => true)
  end
  
  desc 'Reset'
  task :reset => :environment do
    # Drop the snorby database if it exists
    Rake::Task['db:drop'].invoke
    # Invoke the snorby:setup rake task
    Rake::Task['snorby:setup'].invoke
  end
  
end