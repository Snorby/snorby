namespace :snorby do
  
  desc 'Setup'
  task :setup => :environment do
    
    # Create the snorby database if it does not currently exist
    Rake::Task['db:create'].invoke
    
    # Setup the snorby database
    Rake::Task['db:autoupgrade'].invoke
    
    # Load Default Records
    Rake::Task['db:seed'].invoke
    
  end
  
  desc 'Reset'
  task :reset => :environment do
    
    # Drop the snorby database if it exists
    Rake::Task['db:drop'].invoke
    
    # Invoke the snorby:setup rake task
    Rake::Task['snorby:setup'].invoke
    
  end
  
  desc 'Remove Old CSS/JS packages and re-bundle'
  task :refresh => :environment do
    
    # Drop all css/js packages
    Rake::Task['asset:packager:delete_all'].invoke
    
    # bundle all css/js packages
    Rake::Task['asset:packager:build_all'].invoke
    
  end
  
end