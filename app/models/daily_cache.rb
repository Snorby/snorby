class DailyCache
 
  include DataMapper::Resource
  
  storage_names[:default] = "caches"

  property :id, Serial

  property :sid, Integer

  property :cid, Integer

  property :ran_at, DateTime

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

  def self.cache_time
    return get_last.ran_at if get_last
  end

  def self.get_last
    first(:order => [:ran_at.desc])
  end

  def self.this_year
    all(:ran_at.gte => Time.zone.now.beginning_of_year, :ran_at.lte => Time.zone.now.end_of_year)
  end

  def self.this_quarter
    all(:ran_at.gte => Time.zone.now.beginning_of_quarter, :ran_at.lte => Time.zone.now.end_of_quarter)
  end

  def self.last_month
    all(:ran_at.gte => (Time.zone.now - 1.months).beginning_of_month, :ran_at.lte => (Time.zone.now - 1.months).end_of_month)
  end

  def self.this_month
    all(:ran_at.gte => Time.zone.now.beginning_of_month, :ran_at.lte => Time.zone.now.end_of_month)
  end

  def self.last_week
    all(:ran_at.gte => (Time.zone.now - 1.week).beginning_of_week, :ran_at.lte => (Time.zone.now - 1.week).end_of_week)
  end

  def self.this_week
    all(:ran_at.gte => Time.zone.now.beginning_of_week, :ran_at.lte => Time.zone.now.end_of_week)
  end

  def self.yesterday
    all(:ran_at.gte => (Time.zone.now - 1.day).beginning_of_day, :ran_at.lte => (Time.zone.now - 1.day).end_of_day)
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

    if @cache.empty?

      range_for_type(type) do |i|
        count << 0
      end

    else

      range_for_type(type) do |i|
        if @cache.has_key?(i)
          count << @cache[i].map(&:"#{protocol}_count").sum
        else
          count << 0
        end
      end

    end

    count
  end

  def self.severity_count(severity, type=:week)
    count = []
    @cache = cache_for_type(self, type)

    severity_type = {
      :high => 1,
      :medium => 2,
      :low => 3
    }

    if @cache.empty?
      range_for_type(type) do |i|
        count << 0
      end
    else

      range_for_type(type) do |i|

        if @cache.has_key?(i)
          sev_count = 0
          
          @cache[i].map(&:severity_metrics).each do |x|
            sev_count += (x.kind_of?(Hash) ? (x.has_key?(severity_type[severity.to_sym]) ? x[severity_type[severity.to_sym]] : 0) : 0)
          end

          count << sev_count

        else
          count << 0
        end

      end
    end

    count
  end

  def self.sensor_metrics(type=:week)
    @metrics = []

    Sensor.all(:limit => 5, :order => [:events_count.desc]).each do |sensor|
      count = []
      time_range = []

      @cache = cache_for_type(self, type, sensor)

      if @cache.empty?

        range_for_type(type) do |i|
          time_range << "'#{i}'"
          count << 0
        end

      else

        range_for_type(type) do |i|
          time_range << "'#{i}'"

          if @cache.has_key?(i)
            count << @cache[i].map(&:event_count).sum
          else
            count << 0
          end

        end

      end

      @metrics << { :name => sensor.sensor_name, :data => count, :range => time_range }
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

  def self.cache_for_type(collection, type=:week, sensor=false)
    case type.to_sym
    when :week, :last_week
      return collection.group_by { |x| x.ran_at.day } unless sensor
      return collection.all(:sid => sensor.sid).group_by { |x| x.ran_at.day }
    when :month, :last_month
      return collection.group_by { |x| x.ran_at.day } unless sensor
      return collection.all(:sid => sensor.sid).group_by { |x| x.ran_at.day }
    when :year, :quarter
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

      ((Time.zone.now.beginning_of_week.to_date)..(Time.zone.now.end_of_week.to_date)).to_a.each do |i|
        block.call(i.day) if block
      end

    when :last_week

      (((Time.zone.now - 1.week).beginning_of_week.to_date)..((Time.zone.now - 1.week).end_of_week.to_date)).to_a.each do |i|
        block.call(i.day) if block
      end

    when :month

      ((Time.zone.now.beginning_of_month.to_date)..(Time.zone.now.end_of_month.to_date)).to_a.each do |i|
        block.call(i.day) if block
      end

    when :last_month

      (((Time.zone.now - 1.month).beginning_of_month.to_date)..((Time.zone.now - 1.month).end_of_month.to_date)).to_a.each do |i|
        block.call(i.day) if block
      end

    when :quarter

      ((Time.zone.now.beginning_of_quarter.month)..(Time.zone.now.end_of_quarter.month)).to_a.each do |i|
        block.call(i) if block
      end

    when :year

      Time.zone.now.beginning_of_year.month.upto(Time.zone.now.end_of_year.month) do |i|
        block.call(i) if block
      end

    else

      ((Time.zone.now.beginning_of_week.to_date)..(Time.zone.now.end_of_week.to_date)).to_a.each do |i|
        block.call(i.day) if block
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
