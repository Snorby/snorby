class Event

  include DataMapper::Resource
  extend ActionView::Helpers::TextHelper

  storage_names[:default] = "event"

  property :sid, Integer, :key => true, :index => true
  
  property :cid, Integer, :key => true, :index => true
  
  property :sig_id, Integer, :field => 'signature', :index => true
  
  property :timestamp, DateTime

  belongs_to :sensor, :parent_key => :sid, :child_key => :sid, :required => true
  
  belongs_to :signature, :child_key => :sig_id, :parent_key => :sig_id

  belongs_to :ip, :parent_key => [ :sid, :cid ], :child_key => [ :sid, :cid ], :required => true
  
  has 1, :icmp, :parent_key => [ :sid, :cid ], :child_key => [ :sid, :cid ]
  
  has 1, :tcp, :parent_key => [ :sid, :cid ], :child_key => [ :sid, :cid ]
  
  has 1, :udp, :parent_key => [ :sid, :cid ], :child_key => [ :sid, :cid ]
  
  has 1, :opt, :parent_key => [ :sid, :cid ], :child_key => [ :sid, :cid ]

  def json_time
    "{time:'#{timestamp}'}"
  end
  
  def pretty_time
    "#{timestamp.strftime('%D %I:%M:%S %p')} #{User.current_user.timezone}"
  end
  
  def self.to_json_since(time)
    events = Event.all(:timestamp.gt => time)
    json = {:events => []}
    events.each do |event|
      json[:events] << {
        :sid => event.sid,
        :cid => event.cid,
        :hostname => event.sensor.hostname,
        :severity => event.signature.severity,
        :ip_src => event.ip.ip_src.to_s,
        :src_port => event.src_port,
        :ip_dst => event.ip.ip_dst.to_s,
        :dst_port => event.dst_port,
        :timestamp => event.pretty_time,
        :message => truncate(event.signature.name, :length => 40, :omission => '...')
      }
      # :message => truncate(event.signature.name, :length => 40, :omission => '...'),
    end
    return json
  end

  def icmp?
    return true unless icmp.blank?
    false
  end
  
  def tcp?
    return true unless tcp.blank?
    false
  end
  
  def udp?
    return true unless udp.blank?
    false
  end
  
  def src_port
    if icmp?
      return 0
    elsif tcp?
      return tcp.tcp_sport
    else
      return udp.udp_sport
    end
  end
  
  def dst_port
    if icmp?
      return 0
    elsif tcp?
      return tcp.tcp_dport
    else
      return udp.udp_dport
    end
  end

end
