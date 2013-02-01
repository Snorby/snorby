require 'snorby/model/counter'

class Signature

  include DataMapper::Resource
  include Snorby::Model::Counter

  storage_names[:default] = "signature"

  belongs_to :category, :parent_key => :sig_class_id, :child_key => :sig_class_id, :required => true

  has n, :events, :parent_key => :sig_id, :child_key => :sig_id, :constraint => :destroy
  
  has n, :notifications, :child_key => :sig_id, :parent_key => :sig_id
  
  belongs_to :severity, :child_key => :sig_priority, :parent_key => :sig_id
  
  has n, :sig_references, :parent_key => :sig_id, :child_key => [ :sig_id ]

  property :sig_id, Serial, :key => true, :index => true, :min => 0

  property :sig_class_id, Integer, :index => true, :min => 0

  property :sig_name, Text
  
  property :sig_priority, Integer, :index => true, :min => 0
    
  property :sig_rev, Integer, :lazy => true, :min => 0
      
  property :sig_sid, Integer, :lazy => true, :min => 0

  property :sig_gid, Integer, :lazy => true, :min => 0

  property :events_count, Integer, :index => true, :default => 0, :min => 0

  def refs
    sig_references 
  end

  def severity_id
    sig_priority
  end
  
  def name
    sig_name
  end

  #
  #  
  # 
  def event_percentage(in_words=false, count=Event.count)
    begin
      if in_words
        "#{self.events_count}/#{count}"
      else
        return 0 if Event.count.zero?
         "%.2f" % ((self.events_count.to_f / count.to_f) * 100).round(2)
      end
    rescue FloatDomainError
      0
    end
  end

  def self.sorty(params={})
    sort = params[:sort]
    direction = params[:direction]

    page = {
      :per_page => User.current_user.per_page_count
    }

    page.merge!(:order => sort.send(direction))

    page(params[:page].to_i, page)
  end

end
