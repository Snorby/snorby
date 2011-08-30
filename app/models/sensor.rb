class Sensor

  include DataMapper::Resource

  storage_names[:default] = "sensor"

  property :sid, Serial, :key => true, :index => true

  property :name, String, :default => 'Click To Change Me'

  property :hostname, Text, :index => true

  property :interface, Text

  property :filter, Text

  property :detail, Integer, :index => true

  property :encoding, Integer, :index => true

  property :last_cid, Integer, :index => true

  property :events_count, Integer, :index => true, :default => 0

  # Packet Capture Options
  property :packet_capture_url, Text
  property :packet_capture_auth, Boolean, :index => true, :default => false
  property :packet_capture_user, String
  property :packet_capture_password, String

  has n, :events, :child_key => :sid, :constraint => :destroy

  has n, :ips, :child_key => :sid, :constraint => :destroy
  
  has n, :notes, :child_key => :sid, :constraint => :destroy

  def cache
    Cache.all(:sid => sid)
  end
  
  def sensor_name
    return name unless name == 'Click To Change Me'
    hostname
  end

  def events_count_or_find
   events_count.zero? ? events.count : events_count 
  end

  def daily_cache
    DailyCache.all(:sid => sid)
  end

  def last
    return Event.get(sid, last_cid) unless last_cid.blank?
    false
  end
  
  #
  #  Sensor Percentage
  # 
  def event_percentage
    begin
      total_event_count = Sensor.all.map(&:events_count).sum
      ((self.events_count_or_find.to_f / total_event_count.to_f) * 100).round(2)
    rescue FloatDomainError
      0
    end
  end

end
