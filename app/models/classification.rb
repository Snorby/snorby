require 'snorby/model/counter'

class Classification

  include DataMapper::Resource
  include Snorby::Model::Counter

  property :id, Serial, :index => true

  property :name, String

  property :description, Text

  property :hotkey, Integer, :index => true

  property :locked, Boolean, :default => false, :index => true

  property :events_count, Integer, :index => true, :default => 0

  has n, :events, :constraint => :destroy

  validates_uniqueness_of :hotkey
  
  validates_presence_of :name
  
  validates_presence_of :description

  def shortcut
    "f#{hotkey}"
  end

  #
  #  
  # 
  def event_percentage
    begin
      ((self.events_count.to_f / Event.count.to_f) * 100).round(2)
    rescue FloatDomainError
      0
    end
  end
  
  
  def self.to_graph
    graph = []
    all.each do |classification|
      graph << {
        :name => classification.name,
        :data => classification.events_count
      }
    end
    graph
  end
  
  def self.to_pie
    graph = []
    all.each do |classification|
      graph << [classification.name, classification.events_count] unless classification.events_count.zero?
    end
    graph
  end

end
