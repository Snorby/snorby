require 'snorby/model'

class Ip
  include Snorby::Model

  set_table_name "iphdr"
  
  belongs_to :sensor, :foreign_key => [:sid]
  has_many :events, :dependent => :destroy, :foreign_key => [:sid, :cid]

  validates_presence_of :sensor

end
