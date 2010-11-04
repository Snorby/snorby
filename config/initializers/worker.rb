Delayed::Worker.destroy_failed_jobs = false
Delayed::Worker.max_attempts = 3

unless Snorby::Worker.running?
  Thread.new do
    Snorby::Worker.new(:start).perform
  end
end
