require 'stalker'
require 'daemons'
require 'yaml'

module Snorby
  module Worker

    @pid_path = "#{RAILS_ROOT}/tmp/pids/snorby-worker.pid"

    def self.start(verbose = false)
      @verbose = verbose
      start_worker unless working?
    end
    
    def self.working?
      return @worker.running? if defined?(@worker)
      false
    end
    
    def self.workers
      pids.count.to_i
    end

    def self.kill
      file = File.open(@pid_path) if File.exists?(@pid_path)
      yaml_pids = YAML.load_file(file) if file
      if yaml_pids.has_key?(:pids)
        yaml_pids[:pids].collect { |p| `kill #{p}` } unless yaml_pids[:pids].empty?
        clear_pids
      end
    end

    def self.pid
      pids.last
    end

    def self.pids
      file = File.open(@pid_path) if File.exists?(@pid_path)
      if file
        yaml_pids = YAML.load_file(file)
        return yaml_pids[:pids] if yaml_pids.has_key?(:pids)
      else
        return []
      end
    end

    private

      def self.start_worker
        @worker = Daemons.call(:multiple => true, :ontop => @verbose) do
          $stdout = File.new("#{RAILS_ROOT}/log/snorby-worker.log", 'w+')
          require 'snorby/jobs.rb'
          Stalker.work
        end
        write_pid
        @worker
      end

      def self.clear_pids
        pids = { :pids => [] }.to_yaml
        @pid_file = File.open(@pid_path, "w+") do |file|
          file.write pids
        end
      end

      def self.write_pid
        new_pids = pids
        new_pids << @worker.pid.pid if @worker
        pids = { :pids => new_pids }.to_yaml
        @pid_file = File.open(@pid_path, "w+") do |file|
          file.write pids
        end
      end

  end
end
