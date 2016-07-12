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

  def src_asset_name 
 
    RequestStore.store[:assets] ||= {}
    matches =  RequestStore.store[:assets].fetch("#{self.sid}_#{self.ip_src.to_i}", nil)
    return matches if matches
    
    sql = %{
      select name, id, global, ip_address from asset_names a 
      left outer join agent_asset_names b on
      a.id = b.asset_name_id and b.sensor_sid = ?
      where ip_address = ? and
      (global = true or b.sensor_sid is not null)
      order by global desc
      limit 1
    }

    matches = AssetName.find_by_sql([sql, self.sid, self.ip_src.to_i])
    if matches
      RequestStore.store[:assets]["#{self.sid}_#{self.ip_src.to_i}"] = matches.first
      return matches.first
    else
      nil
    end
  end

  def dst_asset_name 

    RequestStore.store[:assets] ||= {}
    matches =  RequestStore.store[:assets].fetch("#{self.sid}_#{self.ip_dst.to_i}", nil)
    return matches if matches

    sql = %{
      select name, id, global, ip_address from asset_names a 
      left outer join agent_asset_names b on
      a.id = b.asset_name_id and b.sensor_sid = ?
      where ip_address = ? and
      (global = true or b.sensor_sid is not null)
      order by global desc
      limit 1
    }
    
    matches = AssetName.find_by_sql([sql, self.sid, self.ip_dst.to_i])
    if matches
      RequestStore.store[:assets]["#{self.sid}_#{self.ip_dst.to_i}"] = matches.first
      return matches.first
    else
      nil
    end
  end

  def asset_names 

    @asset_names ||= {}

    if @asset_names.empty?
   
      @asset_names = {
        :source => src_asset_name,
        :destination => dst_asset_name 
      }

    end
    
    @asset_names
  end

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
