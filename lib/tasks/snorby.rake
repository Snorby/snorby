# Snorby - All About Simplicity.
#
# Copyright (c) 2012 Dustin Willis Webber (dustin.webber at gmail.com)
#
# Snorby is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Foobar is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Foobar.  If not, see <http://www.gnu.org/licenses/>.

require "./lib/snorby/dm/types"
require "./lib/snorby/jobs"
require "./lib/snorby/worker"

namespace :snorby do

  desc 'Setup'  
  task :setup => :environment do
        
    Rake::Task['secret'].invoke
    
    # Create the snorby database if it does not currently exist
    Rake::Task['db:create'].invoke
    
    # Snorby update logic 
    Rake::Task['snorby:update'].invoke
  end
  
  desc 'Update Snorby'
  task :update => :environment do

    # Setup the snorby database
    Rake::Task['db:autoupgrade'].invoke
    
    # Load Default Records
    Rake::Task['db:seed'].invoke

    # Restart Worker
    Rake::Task['snorby:restart_worker'].invoke
  end

  desc 'Update Snorby DB'
  task :dbupdate => :environment do

    # Setup the snorby database
    Rake::Task['db:autoupgrade'].invoke
    
    # Load Default Records
    Rake::Task['db:seed'].invoke
  end

  desc 'Remove Old CSS/JS packages and re-bundle'
  task :refresh => :environment do
    `jammit`
  end

  desc 'Start Snorby Worker if not running'
  task :start_worker => :environment do

    if Snorby::Worker.running?
      exit 0
    end
    
    # otherwise, restart worker.
    Rake::Task['snorby:restart_worker'].invoke
  end

  desc 'Restart Worker/Jobs'
  task :restart_worker => :environment do

    if Snorby::Worker.running?
      puts '* Stopping the Snorby worker process.'
      Snorby::Worker.stop
    end

    count = 0
    stopped = false
    while !stopped 
      
      stopped = true unless Snorby::Worker.running?
      sleep 5 

      count += 1
      if count > 10
        STDERR.puts "[X] Error: Unable to stop the Snorby worker process."
        exit -1
      end
    end

    unless Snorby::Worker.running?
      puts "* Removing old jobs"
      Snorby::Jobs.find.all.destroy

      puts "* Starting the Snorby worker process."
      Snorby::Worker.start
      
      count = 0
      ready = false
      while !ready 
        
        ready = true if Snorby::Worker.running?
        sleep 5 

        count += 1
        if count > 10
          ready  = true
        end
      end


      if Snorby::Worker.running?
        Snorby::Jobs.find.all.destroy
        puts "* Adding jobs to the queue"
        Snorby::Jobs.run_now!
      else
        STDERR.puts "[X] Error: Unable to start the Snorby worker process."
        exit -1
      end
    end

  end
  
  desc 'Soft Reset - Reset Snorby metrics'
  task :soft_reset => :environment do
    
    # Reset Counter Cache Columns
    puts 'Reseting Snorby metrics and counter cache columns'
    Severity.update!(:events_count => 0)
    Sensor.update!(:events_count => 0)
    Signature.update!(:events_count => 0)

    puts 'This could take awhile. Please wait while the Snorby cache is rebuilt.'
    Snorby::Jobs.reset_cache(:all, true)
  end
  
  desc 'Hard Reset - Rebuild Snorby Database'
  task :hard_reset => :environment do
    
    # Drop the snorby database if it exists
    Rake::Task['db:drop'].invoke
    
    # Invoke the snorby:setup rake task
    Rake::Task['snorby:setup'].invoke
    
  end
  
end
