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
  
  def protos
    protos = []
    protos << ['TCP', tcp_count]
    protos << ['UDP', udp_count]
    protos << ['ICMP', icmp_count]
    protos.to_json
  end

end
