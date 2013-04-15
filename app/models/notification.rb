require 'snorby/model'

class Notification
  include Snorby::Model
  include DataMapper::Validate
  include DataMapper::Resource

  property :id, Serial
  
  property :description, Text
  
  property :sig_id, Integer
  
  property :ip_src, String
  
  property :ip_dst, String
  
  property :user_id, Integer
  
  property :user_ids, Object
  
  property :sensor_ids, Object

  # Define created_at and updated_at timestamps
  # timestamps :at

  property :created_at, ZonedTime
  property :updated_at, ZonedTime

  belongs_to :user

  belongs_to :signature, :child_key => :sig_id, :parent_key => :sig_id

  def check(event)
    
    if sensor_ids.blank?
      
      puts 'nope! no sensor'
      
      return check_for_src_ip(event.ip.ip_src) unless ip_src.blank?
      return check_for_dst_ip(event.ip.ip_dst) unless ip_dst.blank?
      
      return true
      
    else

      if sensor_ids.include?(event.sid.to_s)
        puts 'sensor!'
        return check_for_src_ip(event.ip.ip_src.to_s) unless ip_src.blank?
        return check_for_dst_ip(event.ip.ip_dst.to_s) unless ip_dst.blank?

        return true
        
      else
        
        return false
        
      end
    end
    
    return false
  end
  
  private
  
  def check_for_dst_ip(ip)
    if ip_dst == ip
      return true
    else
      return false
    end
  end
  
  def check_for_src_ip(ip)
    if ip_src == ip
      return true
    else
      return false
    end
  end

end
