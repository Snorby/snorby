require 'netaddr'
require 'snorby/model/counter'
require 'snorby/pager'

class Event

  include DataMapper::Resource
  include Snorby::Model::Counter

  #
  # Cache Helpers
  #
  include Snorby::Jobs::CacheHelper

  # Included for the truncate helper method.
  extend ActionView::Helpers::TextHelper

  SIGNATURE_URL = "http://rootedyour.com/snortsid?sid=$$gid$$-$$sid$$"

  storage_names[:default] = "event"


  property :sid, Integer, :key => true, :index => [ :sid_index, :index_timestamp_cid_sid ], :min => 0

  property :cid, Integer, :key => true, :index => [ :cid_index, :index_timestamp_cid_sid ], :min => 0

  property :sig_id, Integer, :field => 'signature', :index => true, :min => 0

  property :classification_id, Integer, :index => true, :required => false, :min => 0

  property :users_count, Integer, :index => true, :default => 0, :min => 0

  property :user_id, Integer, :index => true, :required => false, :min => 0

  property :notes_count, Integer, :index => true, :default => 0, :min => 0

  # 1 = nids
  # 2 = hids
  # others TBD
  property :type, Integer, :default => 1, :min => 0 

  # Fake Column
  property :number_of_events, Integer, :default => 0, :min => 0
  #
  # property :event_id, Integer
  ###

  belongs_to :classification

  property :timestamp, ZonedTime, :index => :index_timestamp_cid_sid

  has n, :favorites, :parent_key => [ :sid, :cid ], 
    :child_key => [ :sid, :cid ], :constraint => :destroy!

  has n, :users, :through => :favorites

  has 1, :severity, :through => :signature, :via => :sig_priority

  has 1, :payload, :parent_key => [ :sid, :cid ], 
    :child_key => [ :sid, :cid ], :constraint => :destroy!

  has 1, :icmp, :parent_key => [ :sid, :cid ], 
    :child_key => [ :sid, :cid ], :constraint => :destroy!

  has 1, :tcp, :parent_key => [ :sid, :cid ], 
    :child_key => [ :sid, :cid ], :constraint => :destroy!

  has 1, :udp, :parent_key => [ :sid, :cid ], 
    :child_key => [ :sid, :cid ], :constraint => :destroy!

  has 1, :opt, :parent_key => [ :sid, :cid ], 
    :child_key => [ :sid, :cid ], :constraint => :destroy!

  has n, :notes, :parent_key => [ :sid, :cid ], 
    :child_key => [ :sid, :cid ], :constraint => :destroy!

  belongs_to :user

  belongs_to :sensor, :parent_key => :sid, 
    :child_key => :sid, :required => true

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
    :user_count => 'event',
    :number_of_events => 'event'
  }

  def self.last_event_timestamp
    event = first(:order => [:timestamp.desc])
    timestamp = event ? event.timestamp : Time.zone.now
  end

  def hids?
    return true if self.signature.name =~ /\[HIDS\]/
    false
  end

  def helpers
    ActionController::Base.helpers
  end
 

  def self.unique_events_by_source_ip
    data = []

    ips = Ip.all(:limit => 25, :fields => [:ip_src], :unique => true).map(&:ip_src)
    events = ips.collect do |ip| 
      Event.all(:'ip.ip_src' => ip, :order => :timestamp.desc).group_by do |x| 
        x.sig_id
      end
    end

    events.each do |set|
      next if set.blank?
      next if set.values.blank?

      set.each do |key, value|
        
        data << value.first
      end
    end

    data
  end

  def self.sorty(params={}, sql=false, count=false)
    sort = params[:sort]
    direction = params[:direction]

    page = {
      :per_page => (params[:limit] ? params[:limit].to_i : User.current_user.per_page_count.to_i)
    }

    if params.has_key?(:search)
      sql, count = Snorby::Search.build(params[:match_all], false, params[:search])

      sql[0] += " order by #{sort} #{direction}"
      sql[0] += " LIMIT ? OFFSET ?"

      page(params[:page], { 
        :per_page => (params[:limit] ? params[:limit].to_i : User.current_user.per_page_count.to_i),
        :order => :timestamp.desc
      }, sql, count)
    else

      if sql
        
        page(params[:page].to_i, page, sql, count);

      else

        if SORT[sort].downcase == 'event'
          page.merge!(:order => sort.send(direction))
        else
          page.merge!(
            :order => [Event.send(SORT[sort].to_sym).send(sort).send(direction), 
                       :timestamp.send(direction)],
            :links => [Event.relationships[SORT[sort].to_s].inverse]
          )
        end

        unless params.has_key?(:classification_all)
          page.merge!(:classification_id => nil)
        end

        if params.has_key?(:user_events)
          relationship = Event.relationships['user'].inverse

          if page.has_key?(:links)
            page[:links].push(relationship)
          else
            page[:links] = [relationship]
          end
        end

        page(params[:page].to_i, page)
      end

    end
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
    sid, gid = [/\$\$sid\$\$/, /\$\$gid\$\$/]

    @signature_url = if Setting.signature_lookup?
      Setting.find(:signature_lookup) 
    else
      SIGNATURE_URL
    end

    @signature_url.sub(sid, signature.sig_sid.to_s).sub(gid, signature.sig_gid.to_s)
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
    all(:timestamp.gte => 2.month.ago.beginning_of_month, 
        :timestamp.lte => 1.month.ago.end_of_month)
  end

  def self.last_week
    all(:timestamp.gte => 2.week.ago.beginning_of_week, 
        :timestamp.lte => 1.week.ago.end_of_week)
  end

  def self.yesterday
    all(:timestamp.gte => 1.day.ago.beginning_of_day, 
        :timestamp.lte => 1.day.ago.end_of_day)
  end

  def self.today
    all(:timestamp.gte => Time.now.beginning_of_day, 
        :timestamp.lte => Time.now.end_of_day)
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
    all(:timestamp.gte => start_time, :timestamp.lte => end_time, 
        :order => [:timestamp.desc])
  end

  def self.between_time(start_time, end_time)
    all(:timestamp.gte => start_time, :timestamp.lt => end_time, 
        :order => [:timestamp.desc])
  end

  def self.get_collection_id_string(q)
    sql = q.first
    count = q.last

    sql.push(999999999, 0)
    [db_select(sql.first, *(sql.shift; sql)).map {|x| "#{x.sid}-#{x.cid}" }.join(','), db_select(count.first, *(count.shift; count)).first.to_i]
  end

  def self.update_classification_by_session(ids, classification, user_id=nil)
    event_count = 0

    @classification = if classification.to_i.zero?
      "NULL"
    else
      Classification.get(classification.to_i).id
    end

    uid = if user_id
      user_id
    else
      User.current_user.id
    end

    if @classification
      update = "UPDATE `events_with_join` as event SET `classification_id` = #{@classification}, `user_id` = #{uid} WHERE "
      event_data = ids.split(',');
      sql = "select * from events_with_join as event where "
      events = []

      event_data.each_with_index do |e, index|
        event = e.split('-')
        event_count += 1

        events.push("(`sid` = #{event.first.to_i} and `cid` = #{event.last.to_i})") 
      end

      sql += events.join(' OR ')
      @events = db_select(sql)

      classification_sql = []
      @events.each do |event|
        classification_sql.push "(classification_id is NULL AND signature = #{event.signature} AND ip_src = #{event.ip_src} AND ip_dst = #{event.ip_dst} AND sid = #{event.sid})"
      end

      tmp = update += classification_sql.join(" OR ")
      db_execute(tmp)
      db_execute("update classifications set events_count = (select count(*) from event where event.`classification_id` = classifications.id);")

      event_count
    end
  end

  def self.update_classification(ids, classification, user_id=nil)
    event_count = 0

    @classification = if classification.to_i.zero?
      "NULL"
    else
      Classification.get(classification.to_i)
    end

    uid = if user_id
      user_id
    else
      User.current_user.id
    end

    if @classification
      update = "UPDATE `event` SET `classification_id` = #{(@classification == "NULL" ? @classification : @classification.id)}, `user_id` = #{uid} WHERE "
      events = []

      process = lambda do |e|
        event_data = e.split(',')

        event_data.each_with_index do |e, index|
          event_count += 1

          event = e.split('-')
          events.push("(`sid` = #{event.first.to_i} and `cid` = #{event.last.to_i})")

          if ((index + 1) % 10000) == 0
            tmp = update
            tmp += events.join(" OR ")
            tmp += ";"
            db_execute(tmp)
            events = []
          end
        end

        unless events.empty?
          tmp = update
          tmp += events.join(" OR ")
          tmp += ";"
          db_execute(tmp)
          events = []
        end

        db_execute("update classifications set events_count = (select count(*) from event where event.`classification_id` = classifications.id);")
        event_count
      end

      if ids.is_a?(Array)
        process.call(ids.first)
      else
        process.call(ids)
      end

    end
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
    # if Setting.utc?
      # return "#{timestamp.utc.strftime('%H:%M')}" if Date.today.to_date == timestamp.to_date
      # "#{timestamp.strftime('%m/%d/%Y')}"
    # else
      # return "#{timestamp.strftime('%l:%M %p')}" if Date.today.to_date == timestamp.to_date
      # "#{timestamp.strftime('%m/%d/%Y')}"
    # end
    return "#{timestamp.strftime('%l:%M %p')}" if Time.zone.today.to_date == timestamp.to_date
    "#{timestamp.strftime('%m/%d/%Y')}"
  end


  def detailed_json 

    geoip = Setting.geoip?
    ip = self.ip

    event = {
      :sid => self.sid,
      :cid => self.cid,
      :hostname => self.sensor.sensor_name,
      :severity => self.signature.sig_priority,
      :session_count => self.number_of_events,
      :ip_src => self.ip.ip_src.to_s,
      :ip_dst => self.ip.ip_dst.to_s,
      :asset_names => self.ip.asset_names,
      :timestamp => self.pretty_time,
      :datetime => self.timestamp.strftime('%A, %b %d, %Y at %I:%M:%S %p'),
      :message =>  self.signature.name, 
      :geoip => false,
      :src_port => src_port,
      :dst_port => dst_port,
      :users_count => users_count,
      :notes_count => notes_count,
      :sig_id => signature.sig_id,
      :favorite => favorite?

    }

    if geoip
      event.merge!({
        :geoip => true,
        :src_geoip => ip.geoip[:source],
        :dst_geoip => ip.geoip[:destination]
      })
    end

    event
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
   
    if !time
      time = Time.zone.now
    end

    geoip = Setting.geoip?
    events = Event.all(:timestamp.gt => Time.zone.parse(time.to_s), :classification_id => nil, :order => [:timestamp.desc])
    json = {:events => []}

    events.each do |event|
      ip = event.ip

      event = {
        :sid => event.sid,
        :cid => event.cid,
        :hostname => event.sensor.sensor_name,
        :severity => event.signature.sig_priority,
        :ip_src => ip.ip_src.to_s,
        :ip_dst => ip.ip_dst.to_s,
        :timestamp => event.pretty_time,
        :datetime => event.timestamp.strftime('%A, %b %d, %Y at %I:%M:%S %p'),
        :message => event.signature.name,
        :geoip => false
      }

      if geoip
        event.merge!({
          :geoip => true,
          :src_geoip => ip.geoip[:source],
          :dst_geoip => ip.geoip[:destination]
        })
      end

      json[:events] << event
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
    return nil unless protocol_data

    if protocol_data.first == :icmp
      nil
    else
      protocol_data.last.send(:"#{protocol_data.first}_sport")
    end
  end
 
  def rule
    @rule = Snorby::Rule.get({
      :rule_id => signature.sig_sid,
      :generator_id => signature.sig_gid,
      :revision_id => signature.sig_rev
    })

    @rule if @rule.found?
  end

  def destination_port
    return nil unless protocol_data

    if protocol_data.first == :icmp
      nil
    else
      protocol_data.last.send(:"#{protocol_data.first}_dport")
    end
  end
  
  def in_xml
    # add user information
    %{<snorby>#{to_xml}#{ip.to_xml}#{protocol_data.last.to_xml if protocol_data}#{classification.to_xml if classification}#{payload.to_xml if payload}</snorby>}.chomp
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
      :payload => payload,
      :payload_html => payload ? payload.to_html : '',
      :sensor => sensor,
      :favorite => favorite?

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
    elsif udp?
      return udp.udp_sport
    else
      return nil
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
    elsif udp?
      return udp.udp_dport
    else
      return nil
    end
  end

  def self.classify_from_collection(events, classification, user, reclassify=false)
    @classification = Classification.get(classification)
    @user = User.get(user)

    events.each do |event|

      old_classification = if event.classification.present?
        event.classification
      else
        nil
      end

      next if old_classification == @classification
      next if old_classification && reclassify == false

      event.classification = @classification
      event.user_id = @user.id

      if event.save
        @classification.up(:events_count) if @classification
        old_classification.down(:events_count) if old_classification
      else
        Rails.logger.info "ERROR: #{event.errors.inspect}"
      end

    end
  rescue => e
    Rails.logger.info(e.backtrace)        
  end

  def self.build_search_hash(column, operator, value)
   ["#{column} #{operator}", value] 
  end

  def self.search(params, pager={})
    @search = {}
    search = []
    sql = []
    params.each do |key, v|
      column = v['column'].to_sym
      operator = v['operator'].to_sym
      value = v['value']

      if column == :protocol
      else
        sql.push(build_search_hash(SEARCH[column], OPERATOR[operator], value.to_i))
      end
    end

    search.push sql.collect { |x| x.first }.join(" AND ")
    search.push(sql.collect { |x| x.last }.flatten).flatten!

    p search



    @search.merge!({:sid => params[:sid].to_i}) unless params[:sid].blank?

    unless params[:classification_id].blank?
      if params[:classification_id].to_i == 0
        @search.merge!({:classification_id => nil})
      else
        @search.merge!({:classification_id => params[:classification_id].to_i})
      end
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
        range = NetAddr::CIDR.create("#{params[:ip_src]}")
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
        range = NetAddr::CIDR.create("#{params[:ip_dst]}")
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
        @search.merge!({:conditions => ['timestamp >= ? AND timestamp <= ?', 
                       Chronic.parse(params[:timestamp]).beginning_of_day, 
                       Chronic.parse(params[:timestamp]).end_of_day]})
      end

    end

    unless params[:severity].blank?
      @search.merge!({:"signature.sig_priority" => params[:severity].to_i})
    end
  
    search

  rescue NetAddr::ValidationError => e
    {}
  rescue ArgumentError => e
    {}
  end

end
