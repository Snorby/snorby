class PageController < ApplicationController

  def dashboard
    
    puts params[:type]
    
    case params[:type].to_sym
    when :today
      @cache = Cache.today
    when :yesterday
      @cache = Cache.yesterday
    when :week
      @cache = DailyCache.this_week
    when :month
      @cache = DailyCache.this_month
    when :year
      @cache = DailyCache.this_year
    else
      @cache = Cache.today
    end
    
    @tcp ||= @cache.protocol_count(:tcp, params[:type].to_sym)
    @udp ||= @cache.protocol_count(:udp, params[:type].to_sym)
    @icmp ||= @cache.protocol_count(:icmp, params[:type].to_sym)
    @high ||= @cache.severity_count(:high, params[:type].to_sym)
    @medium ||= @cache.severity_count(:medium, params[:type].to_sym)
    @low ||= @cache.severity_count(:low, params[:type].to_sym)
    @sensor_metrics ||= @cache.sensor_metrics(params[:type].to_sym)
    
    @event_count ||= @cache.all.map(&:event_count).sum
    
    @axis ||= @sensor_metrics.last[:range].join(',')
    
    @classifications ||= Classification.all(:order => [:events_count.desc])
    @sensors ||= Sensor.all(:limit => 5, :order => [:events_count.desc])
    @favers ||= User.all(:limit => 5, :order => [:favorites_count.desc])
    
    @last_cache = @cache.get_last ? @cache.get_last.ran_at : Time.now
    
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

  private
  
  def load_records
    
    # @classification_metrics ||= @cache.classification_metrics.sort! { |x,y| 1 <=> x.last }
  end

end
