module Snorby
  
  class Process
    
    attr_accessor :raw

    def initialize(raw)
      @raw = raw.split(/\s+/, 11)
    end

    def raw
      @raw
    end
    
    def columns
      [:user, :pid, :cpu, :memory, :vsv, :rss, :tt, :status, :created_at, :runtime, :command]
    end

    def user
      @raw[0]
    end

    def pid
      @raw[1]
    end

    def cpu
      "#{@raw[2]}"
    end

    def memory
      "#{@raw[3]}"
    end

    def vsv
      @raw[4]
    end

    def rss
      @raw[5]
    end

    def tt
      @raw[6]
    end

    def status
      @raw[7]
    end

    def created_at
      @raw[8]
    end

    def runtime
      @raw[9]
    end

    def command
      @raw[10]
    end

  end
  
end
