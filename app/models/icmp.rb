class Icmp

  set_table_name "icmphdr"

  belongs_to :sensor

  belongs_to :event

  validates_presence_of :sensor
  validates_presence_of :event

end
