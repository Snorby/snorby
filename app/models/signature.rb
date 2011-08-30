require 'snorby/model/counter'

class Signature

  include DataMapper::Resource
  include Snorby::Model::Counter

  storage_names[:default] = "signature"

  #belongs_to :category, :parent_key => :sig_class_id, :child_key => :sig_class_id, :required => true

  has n, :events, :parent_key => :sig_id, :child_key => :sig_id, :constraint => :destroy

  has n, :notifications, :child_key => :sig_id, :parent_key => :sig_id

  belongs_to :severity, :child_key => :sig_priority, :parent_key => :sig_id

  #has n, :sig_references, :parent_key => :sig_rev, :child_key => [ :ref_seq ]

  property :sig_id, Serial, :key => true, :index => true

  property :sig_class_id, Integer, :index => true

  property :sig_name, Text

  property :sig_priority, Integer, :index => true

  property :sig_rev, Integer, :lazy => true

  property :sig_sid, Integer, :lazy => true

  property :sig_gid, Integer, :lazy => true

  property :events_count, Integer, :index => true, :default => 0

  def severity_id
    sig_priority
  end

  def name
    sig_name
  end

  def events_count_or_find
    events_count.zero? ? events.count : events_count
  end

  #
  #  Signature Event Percentage
  # 
  def event_percentage(in_wrods=false)
    total_event_count = Signature.all.map(&:events_count).sum
    if in_wrods
      "#{self.events_count_or_find}/#{total_event_count}"
    else
      ((self.events_count_or_find.to_f / total_event_count.to_f) * 100).round(2)
    end
  rescue FloatDomainError
    0
  end

end
