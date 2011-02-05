class Opt

  set_table_name "opt"

  belongs_to :sensor, :required => true

  belongs_to :event, :required => true

end
