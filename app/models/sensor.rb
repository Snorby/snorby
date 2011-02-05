class Sensor

  set_table_name "sensor"

  has_many :events, :dependent => :destroy

  has_many :ips, :dependent => :destroy
  
  has_many :notes, :dependent => :destroy

  def cache
    Cache.all(:sid => sid)
  end
  
  def sensor_name
    return name unless name == 'Click To Change Me'
    hostname
  end
  
  def daily_cache
    DailyCache.all(:sid => sid)
  end

  def last
    return Event.get(sid, last_cid) unless last_cid.blank?
    false
  end
  
  #
  #  
  # 
  def event_percentage
    begin
      total_event_count = Sensor.all.map(&:events_count).sum
      ((self.events_count.to_f / total_event_count.to_f) * 100).round
    rescue FloatDomainError
      0
    end
  end

end
