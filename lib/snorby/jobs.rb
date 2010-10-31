require 'stalker'
include Stalker

job 'say.hello' do |args|
  sleep 10
  puts "Hello!"
end

error do |e|
  Exceptional.handle(e)
end