# Snorby

* [github.com/Snorby/snorby](http://github.com/Snorby/snorby/)
* [github.com/Snorby/snorby/issues](http://github.com/Snorby/snorby/issues)
* [github.com/Snorby/snorby/wiki](http://github.com/Snorby/snorby/wiki)
* irc.freenode.net #snorby

## Description

Snorby is a ruby on rails web application for network security monitoring that interfaces with current popular intrusion detection systems (Snort, Suricata and Sagan). The basic fundamental concepts behind Snorby are **simplicity**, organization and power. The project goal is to create a free, open source and highly competitive application for network monitoring for both private and enterprise use.

## Requirements

* Snort
* Ruby >= 2.5
* Rails >= 3.0.0

## Install

* Get Snorby from the download section or use the latest edge release via git.

	`git clone git://github.com/Snorby/snorby.git`

* Move into the Snorby directory

	`cd snorby`


* Install Gem Dependencies  (make sure you have bundler installed: `gem install bundler`)
	
Ubuntu 18.04 >

	apt-get install ruby-graphviz ruby-dev ruby ruby-bundler rake ruby-rails 
			
	gem install rubygems-bundler
			
	gem install rbundler -v 1.16.1
			
	gem install bundler -v 1.16.1

	`$ bundle install`
	
	* NOTE: If you get missing gem issues in production use `bundle install --path vendor/cache`

	* If your system gems are updated beyond the gemfile.lock you should use as an example `bundle exec rake snorby:setup` 

	* If running `bundle exec {app}` is painful you can safely install binstubs by `bundle install --binstubs` 
	
* Install wkhtmltopdf

	`pdfkit --install-wkhtmltopdf`

	* If this fails - visit https://github.com/pdfkit/pdfkit#wkhtmltopdf for other options

* Edit the Snorby configuration files

	* `config/snorby_config.yml`
	* `config/database.yml`
	* `config/initializers/mail_config.rb`
	
	* Templates can be found in `config/snorby_config.yml.example`, `config/database.yml.example` and `config/initializers/mail_config.example.rb` respectively.

* Run the Snorby setup

	`rake snorby:setup`
	
	* NOTE: If you get warning such as "already initialized constant PDF", you can fix it by running these commands :

	```
	sed -i 's/\(^.*\)\(Mime::Type.register.*application\/pdf.*$\)/\1if Mime::Type.lookup_by_extension(:pdf) != "application\/pdf"\n\1  \2\n\1end/' vendor/cache/ruby/*.*.*/bundler/gems/ezprint-*/lib/ezprint/railtie.rb
	sed -i 's/\(^.*\)\(Mime::Type.register.*application\/pdf.*$\)/\1if Mime::Type.lookup_by_extension(:pdf) != "application\/pdf"\n\1  \2\n\1end/' vendor/cache/ruby/*.*.*/gems/actionpack-*/lib/action_dispatch/http/mime_types.rb
	sed -i 's/\(^.*\)\(Mime::Type.register.*application\/pdf.*$\)/\1if Mime::Type.lookup_by_extension(:pdf) != "application\/pdf"\n\1  \2\n\1end/' vendor/cache/ruby/*.*.*/gems/railties-*/guides/source/action_controller_overview.textile
	```

* Start Rails

	For instance with `rails server` or `bundle exec rails server` and point a browser to localhost:3000
	or whatever you put in `config/snorby_config.yml`.

* Log in and create new user

	If you selected authentication_mode: database in `config/snorby_config.yml` the default user credentials are:
	* Email: **snorby@example.com**
	* Password: **snorby**
	
	After logging in go to **Administration** / **Users**, click **Add user** and fill out the form to create
	a personal account with administrator privileges before you delete the default user.

* Once all options have been configured and snorby is up and running

	* Make sure you start the Snorby Worker from the Administration page.
	* Make sure that both the `DailyCache` and `SensorCache` jobs are running.
	
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

## License

Please refer to the LICENSE file found in the root of the snorby project.


