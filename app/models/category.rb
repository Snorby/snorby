class Category

  include DataMapper::Resource

  storage_names[:default] = "sig_class"

  property :sig_class_id, Serial

  property :sig_class_name, String

end
