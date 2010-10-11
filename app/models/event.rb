class Event

  include DataMapper::Resource
  
  # # Included for the truncate helper method.
  extend ActionView::Helpers::TextHelper

  storage_names[:default] = "event"

  property :sid, Integer, :key => true, :index => true
  
  property :cid, Integer, :key => true, :index => true
  
  property :sig_id, Integer, :field => 'signature', :index => true
  
  property :timestamp, DateTime

  belongs_to :sensor, :parent_key => :sid, :child_key => :sid, :required => true
  
  belongs_to :signature, :child_key => :sig_id, :parent_key => :sig_id

  belongs_to :ip, :parent_key => [ :sid, :cid ], :child_key => [ :sid, :cid ], :required => true
  
  has 1, :payload, :parent_key => [ :sid, :cid ], :child_key => [ :sid, :cid ]
  
  has 1, :icmp, :parent_key => [ :sid, :cid ], :child_key => [ :sid, :cid ]
  
  has 1, :tcp, :parent_key => [ :sid, :cid ], :child_key => [ :sid, :cid ]
  
  has 1, :udp, :parent_key => [ :sid, :cid ], :child_key => [ :sid, :cid ]
  
  has 1, :opt, :parent_key => [ :sid, :cid ], :child_key => [ :sid, :cid ]

  def json_time
    "{time:'#{timestamp}'}"
  end
  
  def pretty_time
    return "#{timestamp.strftime('%l:%M %p')}" if timestamp.today?
    "#{timestamp.strftime('%M/%D/%Y')}"
  end
  
  # 
  # To Json From Time Range
  # 
  # This method will likely be deprecated
  # in favor of .to_json(:include). Due to
  # the snort schema being legacy this was
  # needed for the time being.
  # 
  # @param [String] time Start timeåå
  # 
  # @return [Hash] hash of events between range.
  # 
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
        :ip_dst => event.ip.ip_dst.to_s,
        :timestamp => event.pretty_time,
        :message => truncate(event.signature.name, :length => 80, :omission => '...')
      }
    end
    return json
  end
  
  def protocol_data
    if tcp?
      return [:tcp, self.tcp]
    elsif udp?
      return [:udp, self.udp]
    else
      return [:icmp, self.icmp]
    end
  end
  
  def in_json
    type, proto = protocol_data
    json = {
      :sid => sid,
      :cid => cid,
      :ip => ip,
      :src_ip => ip.ip_src.to_s,
      :src_port => src_port,
      :dst_ip => ip.ip_dst.to_s,
      :dst_port => dst_port,
      :type => type,
      :proto => proto,
      :payload => payload.to_s
    }
    return json
  end

  #
  # ICMP
  # 
  # @return [Boolean] return true
  # if the event proto was icmp.
  # 
  def icmp?
    return true unless icmp.blank?
    false
  end
  
  #
  # TCP
  # 
  # @retrun [Boolean] return true
  # if the event proto is tcp.
  # 
  def tcp?
    return true unless tcp.blank?
    false
  end
  
  #
  # UDP
  # 
  # @return [Boolean] return true
  # if the event proto is udp.
  # 
  def udp?
    return true unless udp.blank?
    false
  end
  
  #
  # Event Source Port
  # 
  # @return [Boolean] return the source
  # port for the event if available.
  # 
  def src_port
    if icmp?
      return 0
    elsif tcp?
      return tcp.tcp_sport
    else
      return udp.udp_sport
    end
  end
  
  #
  # Event Destination Port
  # 
  # @return [Boolean] return the sestination
  # port for the event if available.
  #
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
