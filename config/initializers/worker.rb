Delayed::Worker.destroy_failed_jobs = false
Delayed::Worker.max_attempts = 3

Thread.new { Snorby::Worker.new(:start).perform } unless Snorby::Worker.running?