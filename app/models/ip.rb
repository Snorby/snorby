require 'snorby/model'

class Ip
  include Snorby::Model

  set_table_name "iphdr"
  
  belongs_to :sensor, :required => true

  has_many :events, :dependent => :destroy

end
