# Snorby

* [snorby.org](http://www.snorby.org)
* [github.com/Snorby/snorby](http://github.com/Snorby/snorby/)
* [github.com/Snorby/snorby/issues](http://github.com/Snorby/snorby/issues)
* [github.com/Snorby/snorby/wiki](http://github.com/Snorby/snorby/wiki)
* irc.freenode.net #snorby

## Description

Snorby is a ruby on rails web application for network security monitoring that interfaces with current popular intrusion detection systems (Snort, Suricata and Sagan). The basic fundamental concepts behind Snorby are simplicity, organization and power. The project goal is to create a free, open source and highly competitive application for network monitoring for both private and enterprise use.

* [Snorby Screenshot](http://snorby.org/snorby.png)

## Demo

URL: [http://demo.snorby.org](http://demo.snorby.org)

User: demo@snorby.org

Pass: snorby

**NOTE** For the full packet capture HTTP basic AUTH use the same credentials.

## Requirements

* Snort
* Ruby >= 1.9.2
* Rails >= 3.0.0 
* ImageMagick >= 6.6.4-5

## Install

* Install ImageMagick

	* Mac OSX:
	
		`brew install imagemagick`

	* Linux:
	
		`apt-get install imagemagick`

* Install Gem Dependencies (make sure you have bundler installed: `gem install bundler`)

	`bundle install`
	
* Install wkhtmltopdf

	`pdfkit --install-wkhtmltopdf # If this fails - visit http://code.google.com/p/wkhtmltopdf/ for more information`
	
* Get Snorby from the download section or use the latest edge release via git.

	`git clone git://github.com/Snorby/snorby.git`

* Install Gem Dependencies (inside the root Snorby directory)

	`$ bundle install`
	
	* NOTE: If you get missing gem issues in production use `bundle install --path vendor/cache`
	
* Run The Snorby Setup

	`rake snorby:setup`
	
* Edit The Snorby Configuration File

	`snorby/app/config/snorby_config.yml`
	
* Edit The Snorby Mail Configurations

	`snorby/app/initializers/mail_config.rb`
	
* Once all options have been configured and snorby is up and running

	* Make sure you start the Snorby Worker from the Administration page.
	* Make sure that both the `DailyCache` and `SensorCache` jobs are running.
	
* Default User Credentials

	* E-mail: **snorby@snorby.org**
	* Password: **snorby**
	
* NOTE - If you do not run Snorby with passenger (http://www.modrails.com) people remember to start rails in production mode.

	`rails -e production`
	
## Updating Snorby

In the root Snorby directory type the following command:

	`git pull origin master`
	
Once the pull has competed successfully run the Snorby update rake task:

	`rake snorby:update`
	
# Helpful Commands

You can open the rails console at anytime and interact with the Snorby environment. Below are a few helpful commands that may be useful:

 * Open the rails console by typing `rails c` in the Snorby root directory
 * You should never really need to run the below commands. They are all available within the
	Snorby interface but documented here just in case.

**Snorby Worker**

	Snorby::Worker.stop      # Stop The Snorby Worker
	Snorby::Worker.start     # Start The Snorby Worker
	Snorby::Worker.restart   # Restart The Snorby Worker

**Snorby Cache Jobs**
	
	# This will manually run the sensor cache job - pass true or false for verbose output
	Snorby::Jobs::SensorCacheJob.new(true).perform`

	# This will manually run the daily cache job - once again passing true or false for verbose output
	Snorby::Jobs::DailyCacheJob.new(true).perform

	# Clear All Snorby Cache - You must pass true to this method call for confirmation.
	Snorby::Jobs.clear_cache

	# If the Snorby worker is running this will start the cache jobs and set the run_at time for the current time.
	Snorby::Jobs.run_now!								

## Snorby Team

 * **Dustin Willis Webber** (Design, Backend Code)
 * **Jason Meller** (InstaSnorby VM)
 * **JJ Cummings** (QC, Testing and Support)

## License

Snorby - All About Simplicity.

Copyright (c) 2010 Dustin Willis Webber (dustin.webber at gmail.com)

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA