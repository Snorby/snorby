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
        uri = if Snorby::CONFIG.has_key?(:geoip_uri)
          URI(Snorby::CONFIG[:geoip_uri])
        else
          URI("http://geolite.maxmind.com/download/geoip/database/GeoLiteCountry/GeoIP.dat.gz")
        end

        resp = Net::HTTP.get_response(uri)

        gzip = lambda do |resp, file|
          gz = Zlib::GzipReader.new(StringIO.new(resp.body.to_s)) 
          file.write(gz.read)
        end

        normal = lambda do |resp, file|
          data = StringIO.new(resp.body.to_s)
          file.write(data.read)
        end

        if resp.is_a?(Net::HTTPOK)
          open("tmp/tmp-snorby-geoip.dat", "wb") do |file|
            if uri.to_s.match(/.gz/)
              gzip.call(resp, file)
            else
              normal.call(resp, file)
            end
          end
        end

        if File.exists?("tmp/tmp-snorby-geoip.dat")
          FileUtils.mv('tmp/tmp-snorby-geoip.dat', 'config/snorby-geoip.dat', :force => true)
        end
        
        Snorby::Jobs.geoip_update.destroy! if Snorby::Jobs.geoip_update?

        Delayed::Job.enqueue(Snorby::Jobs::GeoipUpdatedbJob.new(false), 
                               :priority => 1, 
                               :run_at => 1.week.from_now)
      rescue => e
        puts e
        puts e.backtrace
      end
    end
  end
end
