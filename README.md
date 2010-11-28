# Snorby

* [github.com/Snorby/snorby](http://github.com/Snorby/snorby/)
* [github.com/Snorby/snorby/issues](http://github.com/Snorby/snorby/issues)
* irc.freenode.net #snorby

## Description

Snorby is a ruby on rails web application for network security monitoring that interfaces with current popular intrusion detection systems (Snort, Suricata and Saga). The basic fundamental concepts behind Snorby are simplicity, organization and power. The project goal is to create a free, open source and highly competitive application for network monitoring for both private and enterprise use.

## Requirements

* Snort
* Ruby >= 1.9.2
* Rails >= 3.0.0 
* ImageMagick >= 6.6.4-5

## Install

* Install ImageMagick

	* Mac OSX:
	
		`$ brew install imagemagick`

	* Linux:
	
		`$ apt-get install imagemagick`

* Install Gem Dependencies

	`$ bundle install`
	
* Get Snorby from the download section or use the latest edge release via git.

	`git clone git://github.com/Snorby/snorby.git`

* Install Gem Dependencies (inside the root Snorby directory)

	`$ bundle install`
	
* All Done

## Coming Soon

* Full Packet Capture (OpenFPC)

## Snorby Team

* Dustin Willis Webber

## License

Snorby - A Web interface for Snort.

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