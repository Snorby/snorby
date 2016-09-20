class Cache

  include DataMapper::Resource

  property :id, Serial

  property :sid, Integer

  property :cid, Integer

  property :ran_at, ZonedTime, :index => true

  property :event_count, Integer, :default => 0

  property :tcp_count, Integer, :default => 0

  property :udp_count, Integer, :default => 0

  property :icmp_count, Integer, :default => 0

  property :severity_metrics, Object

  property :signature_metrics, Object

  property :src_ips, Object

  property :dst_ips, Object

  # Define created_at and updated_at timestamps
  timestamps :at
  property :created_at, ZonedTime
  property :updated_at, ZonedTime

  belongs_to :sensor, :parent_key => :sid, :child_key => :sid

  has 1, :event, :parent_key => [ :sid, :cid ], :child_key => [ :sid, :cid ]

  def self.last_month
    all(:ran_at.gte => (Time.zone.now - 2.months).beginning_of_month, :ran_at.lte => (Time.zone.now - 2.months).end_of_month)
  end

  def self.this_quarter
    all(:ran_at.gte => Time.zone.now.beginning_of_quarter, :ran_at.lte => Time.zone.now.end_of_quarter)
  end

  def self.this_month
    all(:ran_at.gte => Time.zone.now.beginning_of_month, :ran_at.lte => Time.zone.now.end_of_month)
  end

  def self.last_week
    all(:ran_at.gte => (Time.zone.now - 1.weeks).beginning_of_week, :ran_at.lte => (Time.zone.now - 1.weeks).end_of_week)
  end

  def self.this_week
    all(:ran_at.gte => Time.zone.now.beginning_of_week, :ran_at.lte => Time.zone.now.end_of_week)
  end

  def self.yesterday
    all(:ran_at.gte => Time.zone.now.yesterday.beginning_of_day, :ran_at.lte => Time.zone.now.yesterday.end_of_day)
  end

  def self.today
    all(:ran_at.gte => Time.zone.now.beginning_of_day, :ran_at.lte => Time.zone.now.end_of_day)
  end

  def self.last_24(first=nil,last=nil)
    current = Time.zone.now
    end_time = last ? last : current
    start_time = first ? first : current.yesterday

    all(:ran_at.gte => start_time, :ran_at.lte => end_time)
  end
  
  def self.cache_time
    if (time = get_last)
      return time.updated_at
    else
      Time.zone.now 
    end
  end

  def self.protocol_count(protocol, type=nil)
    count = count_hash(type)
    
    @cache = cache_for_type(self, :hour)

    case protocol.to_sym
    when :tcp
      @cache.each do |hour, data|
        count[hour] = data.map(&:tcp_count).sum
      end
    when :udp
      @cache.each do |hour, data|
        count[hour] = data.map(&:udp_count).sum
      end
    when :icmp
      @cache.each do |hour, data|
        count[hour] = data.map(&:icmp_count).sum
      end
    end

    count.values
  end

  def self.severity_count(severity, type=nil)
    count = count_hash(type)   
    
    @cache = cache_for_type(self, :hour)

    case severity.to_sym
    when :high
      @cache.each do |hour, data|
        high_count = 0
        data.map(&:severity_metrics).each { |x| high_count += (x.kind_of?(Hash) ? (x.has_key?(1) ? x[1] : 0) : 0) }
        count[hour] = high_count
      end
    when :medium
      @cache.each do |hour, data|
        medium_count = 0
        data.map(&:severity_metrics).each { |x| medium_count += (x.kind_of?(Hash) ? (x.has_key?(2) ? x[2] : 0) : 0) }
        count[hour] = medium_count
      end
    when :low
      @cache.each do |hour, data|
        low_count = 0
        data.map(&:severity_metrics).each { |x| low_count += ( x.kind_of?(Hash) ? (x.has_key?(3) ? x[3] : 0) : 0) }
        count[hour] = low_count
      end
    end

    count.values
  end

  def self.get_last
    first(:order => [:updated_at.desc])
  end

  def self.sensor_metrics(type=nil)
    @metrics = []

    Sensor.all(:limit => 5, :order => [:events_count.desc]).each do |sensor|

      if type == :custom
        count = {} #count_hash(type)

        blah = self.all(:sid => sensor.sid).group_by do |x| 
          time = x.ran_at
          "#{time.year}-#{time.month}-#{time.day}-#{time.hour}"
        end

        blah.each do |hour, data|
          count[hour] = data.map(&:event_count).sum
        end

        @metrics << { 
          :name => sensor.sensor_name, 
          :data => count.values,
          :range => count.keys.collect {|x| "'#{x.split('-')[2]}'" }
        }

      else # if not custom

        count = count_hash(type)

        blah = self.all(:sid => sensor.sid).group_by { |x| "#{x.ran_at.day}-#{x.ran_at.hour}" }

        blah.each do |hour, data|
          count[hour] = data.map(&:event_count).sum
        end

        @metrics << { 
          :name => sensor.sensor_name, 
          :data => count.values,
          :range => count.keys.collect {|x| "'#{x.split('-').last}'" }
        }

      end # custom logic
    end

    @metrics
  end

  def self.src_metrics(limit=20)
    @metrics = {}
    @top = []
    @cache = self.map(&:src_ips).compact
    count = 0

    @cache.each do |ip_hash|

      ip_hash.each do |ip, count|
        if @metrics.has_key?(ip)
          @metrics[ip] += count
        else
          @metrics.merge!({ip => count})
        end
      end
    end

    @metrics.sort{ |a,b| -1*(a[1]<=>b[1]) }.each do |data|
      break if count >= limit
      @top << data
      count += 1
    end
    
    @top
  end

  def self.dst_metrics(limit=20)
    @metrics = {}
    @top = []
    @cache = self.map(&:dst_ips).compact
    count = 0

    @cache.each do |ip_hash|

      ip_hash.each do |ip, count|
        if @metrics.has_key?(ip)
          @metrics[ip] += count
        else
          @metrics.merge!({ip => count})
        end
      end
    end

    @metrics.sort{ |a,b| -1*(a[1]<=>b[1]) }.each do |data|
      break if count >= limit
      @top << data
      count += 1
    end
    
    @top
  end

  def self.signature_metrics(limit=20)
    @metrics = {}
    @top = []
    @cache = self
    count = 0

    @cache.map(&:signature_metrics).each do |data|
      next unless data

      data.each do |id, value|
        if @metrics.has_key?(id)
          temp_count = @metrics[id]
          @metrics.merge!({id => temp_count + value})
        else
          @metrics.merge!({id => value})
        end
      end

    end

    @metrics.sort{ |a,b| -1*(a[1]<=>b[1]) }.each do |data|
      break if count >= limit
      @top << data
      count += 1
    end
    
    @top
  end

  def self.count_hash(type=nil)
    count = {}

    if type == :last_24
      now = Time.zone.now
      # TODO
      # this will need to store the key as day/hour
      
      Range.new(now.yesterday.to_i, now.to_i).step(1.hour) do |seconds_since_epoch|
        time = Time.zone.at(seconds_since_epoch)
        key = "#{time.day}-#{time.hour}"
        count[key] = 0
      end

    else

      if type == :custom
        time_start = Time.zone.now.yesterday.beginning_of_day.to_i
        time_end =  Time.zone.now.yesterday.end_of_day.to_i  

        Range.new(time_start, time_end).step(1.day) do |seconds_since_epoch|
          time = Time.zone.at(seconds_since_epoch)
          key = "#{time.year}-#{time.month}-#{time.day}-#{time.hour}"
          count[key] = 0
        end
      else # if not custom
        if type == :today
          time_start = Time.zone.now.beginning_of_day.to_i
          time_end =  Time.zone.now.end_of_day.to_i
        else
          time_start = Time.zone.now.yesterday.beginning_of_day.to_i
          time_end =  Time.zone.now.yesterday.end_of_day.to_i  
        end

        Range.new(time_start, time_end).step(1.hour) do |seconds_since_epoch|
          time = Time.zone.at(seconds_since_epoch)
          key = "#{time.day}-#{time.hour}"
          count[key] = 0
        end
      end # if custom


    end

    count
  end

  def self.cache_for_type(collection, type=:hour, sensor=false)
    return collection.group_by { |x| "#{x.ran_at.day}-#{x.ran_at.hour}" } unless sensor
    return collection.all(:sid => sensor.sid).group_by do |x| 
      "#{x.ran_at.day}-#{x.ran_at.hour}"
    end
  end

  def self.range_for_type(type=:hour, &block)
    Range.new(Time.zone.now.beginning_of_day.to_i, Time.zone.now.end_of_day.to_i).step(1.hour) do |seconds_since_epoch|
      time = Time.zone.at(seconds_since_epoch)
      key = "#{time.day}-#{time.hour}"
      block.call(key) if block
    end
  end

end
