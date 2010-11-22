class DailyCache

  include DataMapper::Resource

  property :id, Serial

  property :sid, Integer

  property :cid, Integer

  property :ran_at, DateTime

  property :event_count, Integer, :default => 0

  property :tcp_count, Integer, :default => 0

  property :udp_count, Integer, :default => 0

  property :icmp_count, Integer, :default => 0

  property :classification_metrics, Object

  property :severity_metrics, Object

  property :signature_metrics, Object
  
  property :src_ips, Object
  
  property :dst_ips, Object

  # Define created_at and updated_at timestamps
  timestamps :at

  belongs_to :sensor, :parent_key => :sid, :child_key => :sid

  has 1, :event, :parent_key => [ :sid, :cid ], :child_key => [ :sid, :cid ]

  def self.get_last
    first(:order => [:ran_at.desc])
  end

  def self.this_year
    all(:ran_at.gt => Time.now.beginning_of_year, :ran_at.lt => Time.now.end_of_year)
  end

  def self.last_month
    all(:ran_at.gt => (Time.now - 2.months).beginning_of_month, :ran_at.lt => (Time.now - 2.months).end_of_month)
  end

  def self.this_month
    all(:ran_at.gt => Time.now.beginning_of_month, :ran_at.lt => Time.now.end_of_month)
  end

  def self.last_week
    all(:ran_at.gt => (Time.now - 2.weeks).beginning_of_week, :ran_at.lt => (Time.now - 2.weeks).end_of_week)
  end

  def self.this_week
    all(:ran_at.gte => Time.now.beginning_of_week, :ran_at.lte => Time.now.end_of_week)
  end

  def self.yesterday
    all(:ran_at.gte => (Time.now - 1.day).beginning_of_day, :ran_at.lte => (Time.now - 1.day).end_of_day)
  end

  def severities
    severities = []
    severity_metrics.each do |id, count|
      severities << [Severity.get(id).name, count]
    end
    severities.to_json
  end
  
  def self.protocol_count(protocol, type=:week)
    count = []
  
    @cache = cache_for_type(self, type)
  
    case protocol.to_sym
    when :tcp
      @cache.each do |day, data|
        count[day] = data.map(&:tcp_count).sum
        puts data.map(&:tcp_count).sum
      end
    when :udp
      @cache.each do |day, data|
        count[day] = data.map(&:udp_count).sum
      end
    when :icmp
      @cache.each do |day, data|
        count[day] = data.map(&:icmp_count).sum
      end
    end
  
    range_for_type(type) do |i|
      next if count[i]
      count[i] = 0
    end
  
    count.compact
  end

  def self.severity_count(severity, type=:week)
    count = []
    @cache = cache_for_type(self, type)
    
    case severity.to_sym
    when :high
      @cache.each do |day, data|
        high_count = 0
        data.map(&:severity_metrics).each { |x| high_count += (x.kind_of?(Hash) ? (x.has_key?(1) ? x[1] : 0) : 0) }
        count[day] = high_count
      end
    when :medium
      @cache.each do |day, data|
        medium_count = 0
        data.map(&:severity_metrics).each { |x| medium_count += (x.kind_of?(Hash) ? (x.has_key?(2) ? x[2] : 0) : 0) }
        count[day] = medium_count
      end
    when :low
      @cache.each do |day, data|
        low_count = 0
        data.map(&:severity_metrics).each { |x| low_count += ( x.kind_of?(Hash) ? (x.has_key?(3) ? x[3] : 0) : 0) }
        count[day] = low_count
      end
    end
    
    range_for_type(type) do |i|
      next if count[i]
      count[i] = 0
    end
    
    count.compact
  end

  def self.sensor_metrics(type=:week)
    @metrics = []

    Sensor.all(:limit => 5, :order => [:events_count.desc]).each do |sensor|
      count = []

      @cache = cache_for_type(self, type, sensor)

      @cache.each do |day, data|
        count[day] = data.map(&:event_count).sum
      end

      time_range = []

      range_for_type(type) do |i|
        time_range << "'#{i}'"
        next if count[i]
        count[i] = 0
      end

      @metrics << { :name => sensor.name, :data => count.compact, :range => time_range }
    end

    @metrics
  end

  def self.src_metrics(stop_count=10)
    @metrics = {}
    @cache = self.map(&:src_ips).compact
    count = 0
    
    @cache.each do |ip_hash|
      
      return @metrics if count > stop_count.to_i
      
      ip_hash.each do |ip, count|
        if @metrics.has_key?(ip)
          @metrics[ip] += count
        else
          @metrics.merge!({ip => count})
          count += 1
        end
      end
    end
    
    @metrics
  end
  
  def self.dst_metrics(stop_count=10)
    @metrics = {}
    @cache = self.map(&:dst_ips).compact
    count = 0
    
    @cache.each do |ip_hash|
      
      return @metrics if count > stop_count.to_i
      
      ip_hash.each do |ip, count|
        if @metrics.has_key?(ip)
          @metrics[ip] += count
        else
          @metrics.merge!({ip => count})
          count += 1
        end
      end
    end
    
    @metrics
  end

  def self.signature_metrics(stop_count=10)
    @metrics = {}
    @cache = self
    count = 0
    
    @cache.map(&:signature_metrics).each do |data|
      next unless data
      
      return @metrics if count > stop_count.to_i
      
      data.sort_by { |k,v| v <=> v }.each do |id, value|
        if @metrics.has_key?(id)
          temp_count = @metrics[id]
          @metrics.merge!({id => temp_count + value})
        else
          @metrics.merge!({Signature.get(id).sig_name.to_sym => value})
          count += 1
        end
      end
      
    end

    @metrics
  end

  def self.classification_metrics
    @metrics = {}
    @cache = self

    @cache.map(&:classification_metrics).each do |data|
      next unless data
      
      data.each do |id, value|
        if @metrics.has_key?(id)
          temp_count = @metrics[id]
          @metrics.merge!({id => temp_count + value})
        else
          @metrics.merge!({Classification.get(id).name.to_sym => value})
        end
      end
    end

    @metrics
  end

  def self.cache_for_type(collection, type=:week, sensor=false)
    case type.to_sym
    when :week
      return collection.group_by { |x| x.ran_at.day } unless sensor
      return collection.all(:sid => sensor.sid).group_by { |x| x.ran_at.day }
    when :month
      return collection.group_by { |x| x.ran_at.day } unless sensor
      return collection.all(:sid => sensor.sid).group_by { |x| x.ran_at.day }
    when :year
      return collection.group_by { |x| x.ran_at.month } unless sensor
      return collection.all(:sid => sensor.sid).group_by { |x| x.ran_at.month }
    else
      return collection.group_by { |x| x.ran_at.day } unless sensor
      return collection.all(:sid => sensor.sid).group_by { |x| x.ran_at.day }
    end
  end
  
  def self.range_for_type(type=:week, &block)
    
    case type.to_sym
    when :week
      Time.now.beginning_of_week.day.upto(Time.now.end_of_week.day) do |i|
        block.call(i) if block
      end
    when :month
      Time.now.beginning_of_month.day.upto(Time.now.end_of_month.day) do |i|
        block.call(i) if block
      end
    when :year
      start_time_method = :beginning_of_year
      end_time_method = :end_of_year
      Time.now.beginning_of_year.month.upto(Time.now.end_of_year.month) do |i|
        block.call(i) if block
      end
    else
      Time.now.beginning_of_week.day.upto(Time.now.end_of_week.day) do |i|
        block.call(i) if block
      end
    end
    
  end

  def protos
    protos = []
    protos << ['TCP', tcp_count]
    protos << ['UDP', udp_count]
    protos << ['ICMP', icmp_count]
    protos.to_json
  end

end
