class Event

  include DataMapper::Resource

  storage_names[:default] = "event"

  belongs_to :sensor, :parent_key => [ :sid ], :child_key => [ :sid ], :required => true
  
  belongs_to :signature, :parent_key => [ :sig_id ], :child_key => [ :signature ], :required => true

  has n, :ips, :child_key => [ :sid, :cid ]
  
  has n, :icmps, :child_key => [ :sid, :cid ]
  
  has n, :tcps, :child_key => [ :sid, :cid ]
  
  has n, :udps, :child_key => [ :sid, :cid ]
  
  has n, :opts, :child_key => [ :sid, :cid ]

  property :sid, Integer, :key => true
  
  property :cid, Integer, :key => true
  
  property :signature, Integer
  
  property :timestamp, DateTime

end
