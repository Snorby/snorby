class Icmp

  set_table_name "icmphdr"

  belongs_to :sensor, :foreign_key => [:sid]

  belongs_to :event, :foreign_key => [:sid, :cid]

  validates_presence_of :sensor
  validates_presence_of :event

end
