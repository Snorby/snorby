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

  # Define created_at and updated_at timestamps
  timestamps :at

  belongs_to :sensor, :parent_key => :sid, :child_key => :sid

  has 1, :event, :parent_key => [ :sid, :cid ], :child_key => [ :sid, :cid ]

  def self.get_last
    first(:order => [:ran_at.desc])
  end

  def self.last_month
    all(:ran_at.gte => (Time.now - 2.months).beginning_of_month, :ran_at.lte => (Time.now - 2.months).end_of_month)
  end

  def self.this_month
    all(:ran_at.gte => Time.now.beginning_of_month, :ran_at.lte => Time.now.end_of_month)
  end

  def self.last_week
    all(:ran_at.gte => (Time.now - 2.weeks).beginning_of_week, :ran_at.lte => (Time.now - 2.weeks).end_of_week)
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

  def self.severity_count(severity, type=:week)
    count = []
    @cache = self.group_by { |x| x.ran_at.day }

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
    
    case type.to_sym
    when :week
      start_time_method = :beginning_of_week
      end_time_method = :end_of_week
    when :month
      start_time_method = :beginning_of_month
      end_time_method = :end_of_month
    else
      start_time_method = :beginning_of_week
      end_time_method = :end_of_week
    end
    
    time_range = []

    Time.now.send(start_time_method).day.upto(Time.now.send(end_time_method).day) do |i|
      time_range << "'#{Time.now.month}/#{i}'"
      next if count[i]
      count[i] = 0
    end
    
    count.compact
  end

  def self.sensor_metrics(type=:week)
    @metrics = []

    Sensor.all(:limit => 5, :order => [:events_count.desc]).each do |sensor|
      count = []
      blah = self.all(:sid => sensor.sid).group_by { |x| x.ran_at.day }

      blah.each do |day, data|
        count[day] = data.map(&:event_count).sum
      end

      case type.to_sym
      when :week
        start_time_method = :beginning_of_week
        end_time_method = :end_of_week
      when :month
        start_time_method = :beginning_of_month
        end_time_method = :end_of_month
      else
        start_time_method = :beginning_of_week
        end_time_method = :end_of_week
      end

      time_range = []

      Time.now.send(start_time_method).day.upto(Time.now.send(end_time_method).day) do |i|
        time_range << "'#{Time.now.month}/#{i}'"
        next if count[i]
        count[i] = 0
      end

      @metrics << { :name => sensor.name, :data => count.compact, :range => time_range }
    end

    @metrics
  end

  def protos
    protos = []
    protos << ['TCP', tcp_count]
    protos << ['UDP', udp_count]
    protos << ['ICMP', icmp_count]
    protos.to_json
  end

end
