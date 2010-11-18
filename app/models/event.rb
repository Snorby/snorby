require 'snorby/model/counter'

class Event

  include DataMapper::Resource
  include Snorby::Model::Counter
  
  # Included for the truncate helper method.
  extend ActionView::Helpers::TextHelper

  storage_names[:default] = "event"

  property :sid, Integer, :key => true, :index => true

  property :cid, Integer, :key => true, :index => true

  property :sig_id, Integer, :field => 'signature', :index => true

  property :classification_id, Integer, :index => true, :required => false

  property :users_count, Integer, :index => true, :default => 0

  property :notes_count, Integer, :index => true, :default => 0

  belongs_to :classification

  property :timestamp, DateTime

  has n, :favorites, :parent_key => [ :sid, :cid ], :child_key => [ :sid, :cid ], :constraint => :destroy

  has n, :users, :through => :favorites

  has 1, :severity, :through => :signature, :via => :sig_priority

  has 1, :payload, :parent_key => [ :sid, :cid ], :child_key => [ :sid, :cid ], :constraint => :destroy

  has 1, :icmp, :parent_key => [ :sid, :cid ], :child_key => [ :sid, :cid ], :constraint => :destroy

  has 1, :tcp, :parent_key => [ :sid, :cid ], :child_key => [ :sid, :cid ], :constraint => :destroy

  has 1, :udp, :parent_key => [ :sid, :cid ], :child_key => [ :sid, :cid ], :constraint => :destroy

  has 1, :opt, :parent_key => [ :sid, :cid ], :child_key => [ :sid, :cid ], :constraint => :destroy

  has n, :notes, :parent_key => [ :sid, :cid ], :child_key => [ :sid, :cid ], :constraint => :destroy

  belongs_to :sensor, :parent_key => :sid, :child_key => :sid, :required => true

  belongs_to :signature, :child_key => :sig_id, :parent_key => :sig_id

  belongs_to :ip, :parent_key => [ :sid, :cid ], :child_key => [ :sid, :cid ]

  before :destroy do
    self.classification.down(:events_count) if self.classification
    self.signature.down(:events_count) if self.signature
    # Note: Need to decrement Severity, Sensor and User Counts
  end

  def to_param
    "#{sid},#{cid}"
  end

  def self.last_month
    all(:timestamp.gte => 2.month.ago.beginning_of_month, :timestamp.lte => 1.month.ago.end_of_month)
  end

  def self.last_week
    all(:timestamp.gte => 2.week.ago.beginning_of_week, :timestamp.lte => 1.week.ago.end_of_week)
  end

  def self.yesterday
    all(:timestamp.gte => 1.day.ago.beginning_of_day, :timestamp.lte => 1.day.ago.end_of_day)
  end

  def self.today
    all(:timestamp.gte => Time.now.beginning_of_day, :timestamp.lte => Time.now.end_of_day)
  end

  def self.find_classification(classification_id)
    all(:classification_id => classification_id)
  end

  def self.find_signature(sig_id)
    all(:sig_id => sig_id)
  end

  def self.find_sensor(sensor)
    all(:sensor => sensor)
  end
  
  def self.between(start_time, end_time)
    all(:timestamp.gte => start_time, :timestamp.lte => end_time)
  end
  
  def self.between_time(start_time, end_time)
    all(:timestamp.gt => start_time, :timestamp.lt => end_time)
  end

  def self.find_by_ids(ids)
    events = []
    ids.split(',').collect do |e|
      event = e.split('-')
      events << get(event.first, event.last)
    end
    return events
  end

  def id
    "#{sid}-#{cid}"
  end

  def html_id
    "event_#{sid}#{cid}"
  end

  def json_time
    "{time:'#{timestamp}'}"
  end

  def pretty_time
    return "#{timestamp.strftime('%l:%M %p')}" if timestamp.today?
    "#{timestamp.strftime('%m/%d/%Y')}"
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
    events = Event.all(:timestamp.gt => time, :classification_id => 0)
    json = {:events => []}
    events.each do |event|
      json[:events] << {
        :sid => event.sid,
        :cid => event.cid,
        :hostname => event.sensor.hostname,
        :severity => event.signature.severity_id,
        :ip_src => event.ip.ip_src.to_s,
        :ip_dst => event.ip.ip_dst.to_s,
        :timestamp => event.pretty_time,
        :message => truncate(event.signature.name, :length => 80, :omission => '...')
      }
    end
    return json
  end

  def favorite?
    return true if User.current_user.events.include?(self)
    false
  end

  def toggle_favorite
    if self.favorite?
      destroy_favorite
    else
      create_favorite
    end
  end

  def create_favorite
    users << User.current_user
    users.save
  end

  def destroy_favorite
    favorite = Favorite.first(:sid => self.sid, :cid => self.cid, :user => User.current_user)
    favorite.destroy if favorite
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
      :payload => payload.to_ascii,
      :payload_html => payload.to_html
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

  def self.reset_classifications
    all.update(:classification_id => 0)
    Classification.all.each do |classification|
      classification.update(:events_count => 0)
    end
  end
  
  def self.search(params)
    query = {}
    return [] if Event.blank?

    params.each do |key, value|
      
      value.each do |column, v|
        type = v.keys.first
        data = v.values.first
        next if data.blank?

        data = nil if data == 'null'

        if key == "event"
          next unless Event.first.respond_to?(column.to_sym)
        else
          next unless Event.first.respond_to?(key.to_sym)
          next unless Event.first.send(key.to_sym).respond_to?(column.to_sym)
          data = IPAddr.new(data) if Event.first.send(key.to_sym).send(column.to_sym).kind_of? IPAddr
        end

        case type.to_sym
        when :like
          data = "%#{data}%" if data.kind_of? String
        end

        if key == "event"
          query.merge!({ [column, type].join('.').to_sym => data })
        else
          query.merge!({ [key, column, type].join('.').to_sym => data })
        end
        
      end

    end
    
    puts "#################### DEBUG"
    puts query.to_yaml
    puts "#################### DEBUG"
    
    all(query)
  end

end
