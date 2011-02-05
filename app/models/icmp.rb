class Icmp

  set_table_name "icmphdr"

  belongs_to :sensor, :required => true

  belongs_to :event, :required => true

end
