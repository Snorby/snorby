class Lookup
  include DataMapper::Resource

  property :id, Serial

  property :title, String

  property :value, Text


  def build(args={})
    args.fetch(:ip, '')
    args.fetch(:port, '')
    value.sub(/\$\{ip\}/, "#{args[:ip]}").sub(/\$\{port\}/, "#{args[:port]}")
  end

end
