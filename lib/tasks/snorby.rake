namespace :snorby do
  
  desc 'Setup'
  task :setup => :environment do
    Rake::Task['db:create'].invoke
    Rake::Task['db:autoupgrade'].invoke
    SnortSchema.create(:vseq => 107, :ctime => Time.now, :version => "Snorby #{Snorby::VERSION}") if SnortSchema.first.blank?
  end
  
  desc 'Reset'
  task :reset => :environment do
    Rake::Task['db:drop'].invoke
    Rake::Task['db:create'].invoke
    Rake::Task['snorby:setup'].invoke
  end
  
end