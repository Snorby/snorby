class Tcp

  set_table_name "tcphdr"
  
  belongs_to :sensor, :foreign_key => [:sid]
  belongs_to :event, :foreign_key => [:sid, :cid]

end
