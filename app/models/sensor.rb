class Sensor

  include DataMapper::Resource

  storage_names[:default] = "sensor"

  property :sid, Serial, :key => true, :index => true, :min => 0

  property :name, String, :default => 'Click To Change Me'

  property :hostname, Text, :index => true

  property :interface, Text

  property :filter, Text

  property :detail, Integer, :index => true, :min => 0

  property :encoding, Integer, :index => true, :min => 0

  property :last_cid, Integer, :index => true, :min => 0

  property :pending_delete, Boolean, :default => false

  property :updated_at, ZonedTime

  property :events_count, Integer, :index => true, :default => 0, :min => 0

  has n, :agent_asset_names

  has n, :asset_names, :through => :agent_asset_names

  has n, :metrics, 'Cache', :child_key => :sid, :constraint => :destroy!

  has n, :daily_metrics, 'DailyCache', :child_key => :sid, :constraint => :destroy!

  has n, :events, :child_key => :sid, :constraint => :destroy!

  has n, :ips, :child_key => :sid, :constraint => :destroy!

  has n, :notes, :child_key => :sid, :constraint => :destroy!

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
      return 0 if total_event_count.zero?
      "%.2f" % ((self.events_count.to_f / total_event_count.to_f) * 100).round(1)
    rescue FloatDomainError
      0
    end
  end


end
