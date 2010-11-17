class PageController < ApplicationController

  def dashboard
    @tcp ||= Cache.today.map(&:tcp_count)
    @udp ||= Cache.today.map(&:udp_count)
    @icmp ||= Cache.today.map(&:icmp_count)
    
    @tcp_total ||= DailyCache.all.map(&:tcp_count).sum
    @udp_total ||= DailyCache.all.map(&:udp_count).sum
    @icmp_total ||= DailyCache.all.map(&:icmp_count).sum
    
    @event_count ||= DailyCache.all.map(&:event_count).sum
    
    @sensors ||= Sensor.all(:limit => 5, :order => [:events_count.desc])
    
    @favers ||= User.all(:limit => 5, :order => [:favorites_count.desc])
    
    @classifications ||= Classification.all(:order => [:events_count.desc])
    
  end
  
  def search
  end
  
  def results
    @search ||= params[:search]
    @events = Event.search(params[:search]).page(params[:page].to_i, :per_page => @current_user.per_page_count, :order => [:timestamp.desc])
    @classifications ||= Classification.all
  end

end
