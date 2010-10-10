class Event

  include DataMapper::Resource

  storage_names[:default] = "event"

  belongs_to :sensor, :parent_key => :sid, :child_key => :sid, :required => true
  
  belongs_to :signature, 'Signature', :parent_key => :signature, :child_key => :sig_id, :required => true

  has n, :ips, :child_key => [ :sid, :cid ]
  
  has n, :icmps, :child_key => [ :sid, :cid ]
  
  has n, :tcps, :child_key => [ :sid, :cid ]
  
  has n, :udps, :child_key => [ :sid, :cid ]
  
  has n, :opts, :child_key => [ :sid, :cid ]

  property :sid, Integer, :key => true
  
  property :cid, Integer, :key => true
  
  property :signature, Integer
  
  property :timestamp, DateTime

  def json_time
    "{time:'#{timestamp}'}"
  end
  
  # def src_ip
  #   "0"
  # end
  # 
  # def src_port
  #   case self
  #   when icmps
  #     return 0
  #   when tcps
  #     return tcps.src_port
  #   when udps
  #     return udps.src_port
  #   end
  # end
  # 
  # def dst_ip
  #   "0"
  # end
  # 
  # def dst_port
  #   case self
  #   when icmps
  #     return 0
  #   when tcps
  #     return tcps.src_port
  #   when udps
  #     return udps.src_port
  #   end
  # end

end
