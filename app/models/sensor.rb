class Sensor

  include DataMapper::Resource

  storage_names[:default] = "sensor"

  has n, :events, :child_key => :sid, :constraint => :destroy

  has n, :ips, :child_key => :sid, :constraint => :destroy

  property :sid, Serial, :key => true, :index => true

  property :name, String, :default => 'Click To Change Me'

  property :hostname, Text, :index => true

  property :interface, Text

  property :filter, Text

  property :detail, Integer, :index => true

  property :encoding, Integer, :index => true

  property :last_cid, Integer, :index => true

  property :events_count, Integer, :index => true, :default => 0


  def last
    return Event.get(sid, last_cid) unless last_cid.blank?
    false
  end

  def event_percentage
    begin
      if Cache.all.blank? &&
        if self.events_count == 0
          0
        else
          ((self.events_count.to_f / Event.count.to_f) * 100).round(2)
        end
      else
        ((self.events_count.to_f / Cache.last.event_count.to_f) * 100).round(2)
      end
    rescue FloatDomainError
      0
    end
  end

end
