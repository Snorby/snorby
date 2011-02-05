class Opt

  set_table_name "opt"

  belongs_to :sensor, :foreign_key => [:sid]
  belongs_to :event, :foreign_key => [:sid, :cid]

  validates_presence_of :sensor
  validates_presence_of :event

end
