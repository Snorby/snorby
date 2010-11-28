# Snorby - All About Simplicity.
# 
# Copyright (c) 2010 Dustin Willis Webber (dustin.webber at gmail.com)
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

namespace :snorby do
  
  desc 'Setup'
  task :setup => :environment do
    
    # Create the snorby database if it does not currently exist
    Rake::Task['db:create'].invoke
    
    # Setup the snorby database
    Rake::Task['db:autoupgrade'].invoke
    
    # Load Default Records
    Rake::Task['db:seed'].invoke
    
    # bundle all css/js packages
    Rake::Task['asset:packager:build_all'].invoke
    
  end
  
  desc 'Remove Old CSS/JS packages and re-bundle'
  task :refresh => :environment do
    
    # Drop all css/js packages
    Rake::Task['asset:packager:delete_all'].invoke
    
    # bundle all css/js packages
    Rake::Task['asset:packager:build_all'].invoke
    
  end
  
  desc 'Reset'
  task :hard_reset => :environment do
    
    # Drop the snorby database if it exists
    Rake::Task['db:drop'].invoke
    
    # Invoke the snorby:setup rake task
    Rake::Task['snorby:setup'].invoke
    
  end
  
end