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
      @whois ||= Whois::Client.new.lookup(@address)
    end
    
    def hostname
      @hostname ||= Socket::getaddrinfo(@address,nil)[0][2]
    end
    
    def dns
      @dns ||= Resolver(hostname)
    end
    
  end
end
