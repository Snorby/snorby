require 'snorby/model'

class AssetName 

  include DataMapper::Resource
  validates_with_method :validate_asset_name

  property :id, Serial, :key => true

  property :ip_address, NumericIPAddr, :index => true, :min => 0, 
    :required => true, :default => 0

  property :name, String, :length => 1024, :required => true

  property :global, Boolean, :default => true

  has n, :agent_asset_names

  has n, :sensors, :through => :agent_asset_names

  def save_with_sensors(updated_sensors)

    return false unless self.save!

    self.agent_asset_names.destroy!  
 
   if updated_sensors && updated_sensors.length > 0
      updated_sensors.each do |sensor| 
         AgentAssetName.create(:sensor_sid => sensor.sid, :asset_name_id => self.id).save!
      end
    end

    true
  end

  def validate_asset_name
    if !self.global && self.sensors.length == 0
      return [ false, "Non-global asset_names must have at least one sensor." ]
    end

    true
  end

  def agent_ids_string 
    sensors.map(&:sid).join(",")   
  end

  def applies_to
    if self.global
      return 'All Agents'
    end

    return "#{sensors.count} Agents"
  end

  def detailed_json

    return {
      :id => self.id,
      :name => self.name,
      :global => self.global,
      :ip_address => self.ip_address.to_s,
      :sensors => self.sensors.map{|sensor| sensor.sid}
    }
  end

  def self.sorty(params={})
    sort = params[:sort]
    direction = params[:direction]

    page = {
      :per_page => User.current_user.per_page_count
    }

    page.merge!(:order => sort.send(direction))

    page(params[:page].to_i, page)
  end
end


