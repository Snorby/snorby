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
