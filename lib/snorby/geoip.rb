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

require 'geoip'

module Snorby
  module Geoip
   
    PATH = File.join(Rails.root.to_s, 'config', 'snorby-geoip.dat')

    def self.database?
      return false unless File.exists?(PATH)
      File.open(PATH)
    end

    def self.lookup(ip)
      database = self.database?
      return {} unless database
      lookup = GeoIP.new(database).country(ip)
      lookup.to_hash
    rescue ArgumentError => e
      {}
    end

  end
end
