require 'snorby/model'

class Ip
  include Snorby::Model

  set_table_name "iphdr"
  
  belongs_to :sensor
  has_many :events, :dependent => :destroy

  validates_presence_of :sensor

end
