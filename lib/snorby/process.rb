# Snorby - All About Simplicity.
# 
# Copyright (c) 2010 Dustin Willis Webber (dustin.webber at gmail.com)
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

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
