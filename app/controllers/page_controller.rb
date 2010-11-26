class PageController < ApplicationController

  def dashboard
    
    params[:range] = 'today' unless params[:range]
    
    case params[:range].to_sym
    when :today
      @cache = Cache.today
    when :yesterday
      @cache = Cache.yesterday
      @classification_metrics ||= DailyCache.yesterday.classification_metrics
    when :week
      @cache = DailyCache.this_week
      @classification_metrics ||= @cache.this_week.classification_metrics
    when :last_week
      @cache = DailyCache.last_week
      @classification_metrics ||= @cache.last_week.classification_metrics
    when :month
      @cache = DailyCache.this_month
      @classification_metrics ||= @cache.this_month.classification_metrics
    when :last_month
      @cache = DailyCache.last_month
      @classification_metrics ||= @cache.last_month.classification_metrics
    when :quarter
      @cache = DailyCache.this_quarter
      @classification_metrics ||= @cache.this_quarter.classification_metrics
    when :year
      @cache = DailyCache.this_year
      @classification_metrics ||= @cache.this_year.classification_metrics
    else
      @cache = Cache.today
    end
    
    @src_metrics ||= @cache.src_metrics
    @dst_metrics ||= @cache.dst_metrics
    
    @tcp ||= @cache.protocol_count(:tcp, params[:range].to_sym)
    @udp ||= @cache.protocol_count(:udp, params[:range].to_sym)
    @icmp ||= @cache.protocol_count(:icmp, params[:range].to_sym)
    @high ||= @cache.severity_count(:high, params[:range].to_sym)
    @medium ||= @cache.severity_count(:medium, params[:range].to_sym)
    @low ||= @cache.severity_count(:low, params[:range].to_sym)
    @sensor_metrics ||= @cache.sensor_metrics(params[:range].to_sym)
    
    @signature_metrics ||= @cache.signature_metrics
    
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
    limit = params[:limit].to_i.zero? ? @current_user.per_page_count : params[:limit].to_i
    @events = Event.search(params[:search]).page(params[:page].to_i, :per_page => limit, :order => [:timestamp.desc])
    @classifications ||= Classification.all
  end

end
