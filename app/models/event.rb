require 'snorby/model/counter'
require 'snorby/extensions/ip_addr'

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

  property :user_id, Integer, :index => true, :required => false
  
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

  belongs_to :user

  belongs_to :sensor, :parent_key => :sid, :child_key => :sid, :required => true

  belongs_to :signature, :child_key => :sig_id, :parent_key => :sig_id

  belongs_to :ip, :parent_key => [ :sid, :cid ], :child_key => [ :sid, :cid ]

  before :destroy do
    self.classification.down(:events_count) if self.classification
    self.signature.down(:events_count) if self.signature
    # Note: Need to decrement Severity, Sensor and User Counts
  end

   SORT = { 
    :sig_priority => 'signature',
    :sid => 'event',
    :ip_src => 'ip',
    :ip_dst => 'ip',
    :sig_name => 'signature',
    :timestamp => 'event',
    :user_count => 'event'
  }

  def self.sorty(params={})
    p params

    sort = params[:sort]
    direction = params[:direction]

    page = {
      :per_page => User.current_user.per_page_count
    }

    if SORT[sort].downcase == 'event'
      page.merge!(:order => sort.send(direction))
    else
      page.merge!(
        :order => [Event.send(SORT[sort].to_sym).send(sort).send(direction), :timestamp.send(direction)],
        :links => [Event.relationships[SORT[sort].to_s].inverse]
      )
    end
    
    if params.has_key?(:search)
      page.merge!(search(params[:search]))
    else
      page.merge!(:classification_id => nil)
    end

    page(params[:page].to_i, page)
  end

  def packet_capture(params={})
    case Setting.find(:packet_capture_type).to_sym
    when :openfpc
      Snorby::Plugins::OpenFPC.new(self,params).to_s
    when :solera
      Snorby::Plugins::Solera.new(self,params).to_s
    else
      nil
    end
  end

  def signature_url
    if Setting.signature_lookup?
      url = Setting.find(:signature_lookup)
      return url.sub(/\$\$sid\$\$/, signature.sig_sid.to_s).sub(/\$\$gid\$\$/, signature.sig_gid.to_s)
    else
      url = "http://rootedyour.com/snortsid?sid=$$gid$$-$$sid$$"
      return url.sub(/\$\$sid\$\$/, signature.sig_sid.to_s).sub(/\$\$gid\$\$/, signature.sig_gid.to_s)
    end
  end

  def matches_notification?
    Notification.each do |notify|
      next unless notify.sig_id == sig_id
      send_notification if notify.check(self)
    end
    nil
  end

  def send_notification
    Delayed::Job.enqueue(Snorby::Jobs::AlertNotifications.new(self.sid, self.cid))
  end

  def self.limit(limit=25)
    all(:limit => limit)
  end

  def self.order(column=:timestamp, order=:desc)
    all(:order => column.to_sym.send(order.to_sym))
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
    all(:timestamp.gte => start_time, :timestamp.lte => end_time, :order => [:timestamp.desc])
  end

  def self.between_time(start_time, end_time)
    all(:timestamp.gte => start_time, :timestamp.lt => end_time, :order => [:timestamp.desc])
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
    return "#{timestamp.strftime('%l:%M %p')}" if Date.today.to_date == timestamp.to_date
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
    events = Event.all(:timestamp.gt => time, :classification_id => nil, :order => [:timestamp.desc])
    json = {:events => []}
    events.each do |event|
      json[:events] << {
        :sid => event.sid,
        :cid => event.cid,
        :hostname => event.sensor.sensor_name,
        :severity => event.signature.sig_priority,
        :ip_src => event.ip.ip_src.to_s,
        :ip_dst => event.ip.ip_dst.to_s,
        :timestamp => event.pretty_time,
        :message => truncate(event.signature.name, :length => 65, :omission => '...')
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
    favorite = Favorite.create(:sid => self.sid, :cid => self.cid, :user => User.current_user)
  end

  def destroy_favorite
    favorite = User.current_user.favorites.first(:sid => self.sid, :cid => self.cid)
    favorite.destroy! if favorite
  end

  def protocol
    if tcp?
      return :tcp
    elsif udp?
      return :udp
    elsif icmp?
      return :icmp
    else
      nil
    end
  end

  def protocol_data
    if tcp?
      return [:tcp, self.tcp]
    elsif udp?
      return [:udp, self.udp]
    elsif icmp?
      return [:icmp, self.icmp]
    else
      false
    end
  end
  
  def source_port
    if protocol_data.first == :icmp
      nil
    else
      protocol_data.last.send(:"#{protocol_data.first}_sport")
    end
  end
  
  def destination_port
    if protocol_data.first == :icmp
      nil
    else
      protocol_data.last.send(:"#{protocol_data.first}_dport")
    end
  end
  
  def in_xml
    %{<snorby>#{to_xml}#{user.to_xml if user}#{ip.to_xml}#{protocol_data.last.to_xml if protocol_data}#{classification.to_xml if classification}#{payload.to_xml if payload}#{notes.to_xml}</snorby>}
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
  
  def self.classify_from_collection(collection, classification, user, reclassify=false)
    @classification = Classification.get(classification)
    @user ||= User.get(user)

    collection.each do |event|
      next unless event
      old_classification = event.classification || false
      
      next if old_classification == @classification
      
      next if (old_classification && reclassify == false)
      
      event.user = @user

      if @classification.blank?
        event.classification = nil
      else
        event.classification = @classification
      end

      if event.save
        @classification.up(:events_count) if @classification
        old_classification.down(:events_count) if old_classification
      else
        Rails.logger.info "ERROR: #{event.errors.inspect}"
      end
      
    end
  end

  def self.search(params)
    @search = {}

    @search.merge!({:sid => params[:sid].to_i}) unless params[:sid].blank?

    unless params[:classification_id].blank?
      @search.merge!({:classification_id => params[:classification_id].to_i})
    end

    unless params[:signature_name].blank?
      @search.merge!({
        :"signature.sig_name".like => "%#{params[:signature_name]}%"
      })  
    end
    
    unless params[:src_port].blank?
      @search.merge!({:"tcp.tcp_sport" => params[:src_port].to_i})
    end
     
    unless params[:dst_port].blank?
      @search.merge!({:"tcp.tcp_dport" => params[:dst_port].to_i})
    end

    ### IPAddr
    unless params[:ip_src].blank?
      if params[:ip_src].match(/\d+\/\d+/)
        range = IPAddr.each("#{params[:ip_src]}").to_a
        @search.merge!({
          :"ip.ip_src".gte => IPAddr.new(range.first),
          :"ip.ip_src".lte => IPAddr.new(range.last),
        })
      else
        @search.merge!({:"ip.ip_src".like => IPAddr.new("#{params[:ip_src]}")})
      end 
    end

    unless params[:ip_dst].blank?
      if params[:ip_dst].match(/\d+\/\d+/)
        range = IPAddr.each("#{params[:ip_dst]}").to_a
        @search.merge!({
          :"ip.ip_dst".gte => IPAddr.new(range.first),
          :"ip.ip_dst".lte => IPAddr.new(range.last),
        })
      else
        @search.merge!({:"ip.ip_dst".like => IPAddr.new("#{params[:ip_dst]}")})
      end
    end

    unless params[:severity].blank?
      @search.merge!({:"signature.sig_priority" => params[:severity].to_i})
    end

    # Timestamp
    if params[:timestamp].blank?

      unless params[:time_start].blank? || params[:time_end].blank?
        @search.merge!({
          :conditions => ['timestamp >= ? AND timestamp <= ?',
            Time.at(params[:time_start].to_i),
            Time.at(params[:time_end].to_i)
        ]})
      end

    else

      if params[:timestamp] =~ /\s\-\s/
        start_time, end_time = params[:timestamp].split(' - ')
        @search.merge!({:conditions => ['timestamp >= ? AND timestamp <= ?', 
                       Chronic.parse(start_time).beginning_of_day, 
                       Chronic.parse(end_time).end_of_day]})
      else
        @search.merge!({:timestamp.gte => 
                       Chronic.parse(params[:timestamp]).beginning_of_day})
      end

    end

    unless params[:severity].blank?
      @search.merge!({:"signature.sig_priority" => params[:severity].to_i})
    end
  
    @search

  rescue ArgumentError => e
    p e
    {}
  end

end
