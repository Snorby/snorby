# Snorby - A Web interface for Snort.
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

require 'net/dns'
require 'net/dns/resolver'
require 'socket'
require 'whois'

module Snorby
  class Lookup
    
    Socket.do_not_reverse_lookup = false
    attr_accessor :address, :whois, :hostname, :dns
    
    def initialize(address)
      @address = address.to_s
    end
    
    def whois
      @whois = Whois::Client.new.query(@address)
    end
    
    def hostname
      @hostname = Socket::getaddrinfo('210.180.98.85',nil)[0][2]
    end
    
    def dns
      @dns ||= Resolver(@address)
    end
    
  end
end