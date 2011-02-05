require 'snorby/model/counter'

class Signature

  include Snorby::Model::Counter
  
  set_table_name "signature"

  #belongs_to :category, :parent_key => :sig_class_id, :child_key => :sig_class_id, :required => true

  has_many :events, :dependent => :destroy, :foreign_key => [:sig_id]
  
  has_many :notifications, :foreign_key => [:sig_id]
  
  belongs_to :severity, :foreign_key => [:sig_id, :sig_priority]  

  #has n, :sig_references, :parent_key => :sig_rev, :child_key => [ :ref_seq ]

  def severity_id
    sig_priority
  end
  
  def name
    sig_name
  end
  
  #
  #  
  # 
  def event_percentage(in_wrods=false)
    begin
      total_event_count = Signature.all.map(&:events_count).sum
      if in_wrods
        "#{self.events_count}/#{total_event_count}"
      else
        ((self.events_count.to_f / total_event_count.to_f) * 100).round
      end
    rescue FloatDomainError
      0
    end
  end

end
