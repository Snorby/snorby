class PageController < ApplicationController

  def dashboard
    
    @cache = Cache.today
    
    @tcp ||= @cache.map(&:tcp_count)
    @udp ||= @cache.map(&:udp_count)
    @icmp ||= @cache.map(&:icmp_count)
    
    @high ||= @cache.severity_count(:high)
    @medium ||= @cache.severity_count(:medium)
    @low ||= @cache.severity_count(:low)
    
    @event_count ||= @cache.all.map(&:event_count).sum
    
    @sensor_metrics ||= @cache.sensor_metrics
    @classification_metrics ||= @cache.classification_metrics.sort! { |x,y| 1 <=> x.last }
    
    @classifications ||= Classification.all(:order => [:events_count.desc])
    @sensors ||= Sensor.all(:limit => 5, :order => [:events_count.desc])
    @favers ||= User.all(:limit => 5, :order => [:favorites_count.desc])
    
    @last_cache = @cache.last ? @cache.last.ran_at : Time.now
    
    sigs = Event.all(:limit => 5, :order => [:timestamp.desc], :fields => [:sig_id], :unique => true).map(&:signature).map(&:sig_id)
    @recent_events ||= Event.all(:sig_id => sigs).group_by { |x| x.sig_id }.map(&:last).map(&:first)
    
    respond_to do |format|
      format.html
      format.js
      format.pdf do
        render :pdf => "Metrics for #{Time.now}", :template => "page/dashboard.pdf.erb", :layout => 'pdf.html.erb', :stylesheets => ["pdf"]
      end
    end
    
  end
  
  def search
  end
  
  def results
    @search ||= params[:search]
    @events = Event.search(params[:search]).page(params[:page].to_i, :per_page => @current_user.per_page_count, :order => [:timestamp.desc])
    @classifications ||= Classification.all
  end

end
