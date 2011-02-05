class Udp

  set_table_name "udphdr"

  belongs_to :sensor, :foreign_key => [:sid] 
  belongs_to :event, :foreign_key => [:sid, :cid]

end
