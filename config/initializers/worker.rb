# Start The Snorby Worker
Snorby::Worker.new(:start).perform unless Snorby::Worker.running?