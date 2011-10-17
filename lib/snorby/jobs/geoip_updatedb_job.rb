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

module Snorby
  module Jobs
    class GeoipUpdatedbJob < Struct.new(:verbose)
      
      def perform
        
        Net::HTTP.start("geolite.maxmind.com") { |http|
          resp = http.get("/download/geoip/database/GeoLiteCountry/GeoIP.dat.gz")
          open("tmp/GeoIP.dat", "wb") { |file|
            gz = Zlib::GzipReader.new(StringIO.new(resp.body.to_s)) 
            file.write(gz.read)
           }
        }        
        FileUtils.mv('tmp/GeoIP.dat', 'config/snorby-geoip.dat', :force => true)
        
        Snorby::Jobs.geoip_update.destroy! if Snorby::Jobs.geoip_update?

        Delayed::Job.enqueue(Snorby::Jobs::GeoipUpdatedbJob.new(false), 
                               :priority => 1, 
                               :run_at => 1.week.from_now)
        
      end
    end
  end
end