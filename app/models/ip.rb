require 'snorby/model'

class Ip
  include Snorby::Model
  include DataMapper::Resource

  storage_names[:default] = "iphdr"

  property :sid, Integer, :key => true, :index => true
  
  property :cid, Integer, :key => true, :index => true

  property :ip_src, NumericIPAddr, :index => true, :min => 0, 
           :required => true, :default => 0
  
  property :ip_dst, NumericIPAddr, :index => true, :min => 0, 
           :required => true, :default => 0
  
  property :ip_ver, Integer, :lazy => true, :min => 0, :required => true, 
           :default => 0
  
  property :ip_hlen, Integer, :lazy => true, :min => 0, :required => true, 
            :default => 0
  
  property :ip_tos, Integer, :lazy => true, :min => 0, :required => true, 
           :default => 0
  
  property :ip_len, Integer, :lazy => true, :min => 0, :required => true, 
           :default => 0
  
  property :ip_id, Integer, :lazy => true, :min => 0, :required => true, 
           :default => 0
  
  property :ip_flags, Integer, :lazy => true, :min => 0, :required => true, 
           :default => 0
  
  property :ip_off, Integer, :lazy => true, :min => 0, :required => true, 
           :default => 0
  
  property :ip_ttl, Integer, :lazy => true, :min => 0, :required => true, 
            :default => 0
  
  property :ip_proto, Integer, :lazy => true, :min => 0, :required => true, 
           :default => 0
  
  property :ip_csum, Integer, :lazy => true, :min => 0, :required => true, 
           :default => 0
  
  belongs_to :sensor, :parent_key => [ :sid ], :child_key => [ :sid ], 
             :required => true

  has n, :events, :parent_key => [ :sid, :cid ], :child_key => [ :sid, :cid ], 
         :constraint => :destroy

  def geoip
    @geoip_hash ||= {}

    if @geoip_hash.empty?
      @geoip_hash = { 
        :source => Snorby::Geoip.lookup(self.ip_src.to_s), 
        :destination =>  Snorby::Geoip.lookup(self.ip_dst.to_s)
      }
    end

    @geoip_hash
  end

end
