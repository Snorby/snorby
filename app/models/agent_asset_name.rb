
class AgentAssetName

  include DataMapper::Resource

  belongs_to :sensor, :key => true
  belongs_to :asset_name, :key => true


  def self.delete_agent_references(ip_address, sensor_sid)

    sql = %{
     delete a 
     from agent_asset_names a
     inner join asset_names b on a.asset_name_id = b.id
     and b.global = 0 and b.ip_address = ? and a.sensor_sid = ?;
    }

    DataMapper.repository(:default).adapter.execute(sql, ip_address.to_i, sensor_sid)

    # delete any empty references (global = 0 and no agents assigned)
    sql = %{
     select a.id
     from asset_names a
     left outer join agent_asset_names b on b.asset_name_id = a.id
     where a.global = 0 and a.ip_address = ?
     group by a.id
     having count(b.sensor_sid) = 0
    }

    asset_names = AssetName.find_by_sql([sql, ip_address.to_i])
    asset_names.each { |asset| asset.destroy! } if asset_names 

    
  end
end

