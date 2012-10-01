require "snorby/rule"

module Snorby
  
  def self.logger
    DataMapper::Logger.new($stdout)
  end
  
end
