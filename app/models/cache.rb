class Cache

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
    all(:ran_at.gte => 2.month.ago.beginning_of_month, :ran_at.lte => 1.month.ago.end_of_month)
  end

  def self.last_week
    all(:ran_at.gte => 2.week.ago.beginning_of_week, :ran_at.lte => 1.week.ago.end_of_week)
  end

  def self.yesterday
    all(:ran_at.gte => 1.day.ago.beginning_of_day, :ran_at.lte => 1.day.ago.end_of_day)
  end

  def self.today
    all(:ran_at.gte => Time.now.beginning_of_day, :ran_at.lte => Time.now.end_of_day)
  end

end
