require 'snorby/jobs/cache'

module Snorby
  
  module Jobs
    
    def self.find
      Delayed::Backend::DataMapper::Job
    end
    
    def self.run(obj)
      Delayed::Job.enqueue(obj)
    end
    
  end
end