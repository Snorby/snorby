class PageController < ApplicationController

  helper_method :sort_column, :sort_direction, :sort_page

  def dashboard
    @now = Time.now

    @range = params[:range].blank? ? 'last_24' : params[:range]

    set_defaults

    @src_metrics = @cache.src_metrics
    @dst_metrics = @cache.dst_metrics

    @tcp = @cache.protocol_count(:tcp, @range.to_sym)
    @udp = @cache.protocol_count(:udp, @range.to_sym)
    @icmp = @cache.protocol_count(:icmp, @range.to_sym)

    @high = @cache.severity_count(:high, @range.to_sym)
    @medium = @cache.severity_count(:medium, @range.to_sym)
    @low = @cache.severity_count(:low, @range.to_sym)
    
    @sensor_metrics = @cache.sensor_metrics(@range.to_sym)

    @signature_metrics = @cache.signature_metrics

    @event_count = @cache.all.map(&:event_count).sum

     
    if @sensor_metrics.last
      @axis = @sensor_metrics.last[:range].join(',')
    end

    @classifications = Classification.all(:order => [:events_count.desc])
    @sensors = Sensor.all(:limit => 5, :order => [:events_count.desc])
    @favers = User.all(:limit => 5, :order => [:favorites_count.desc])

    @last_cache = @cache.cache_time

    sigs = Event.all(:limit => 5, :order => [:timestamp.desc], :fields => [:sig_id], :unique => true).map(&:signature).map(&:sig_id)
    @recent_events = Event.all(:sig_id => sigs).group_by { |x| x.sig_id }.map(&:last).map(&:first)

    respond_to do |format|
      format.html # { render :template => 'page/dashboard.pdf.erb', :layout => 'pdf.html.erb' }
      format.js
      format.pdf do
        render :pdf => "Snorby Report - #{@start_time.strftime('%A-%B-%d-%Y-%I-%M-%p')} - #{@end_time.strftime('%A-%B-%d-%Y-%I-%M-%p')}", :template => "page/dashboard.pdf.erb", :layout => 'pdf.html.erb', :stylesheets => ["pdf"]
      end
    end

  end

  def search
  end

  def results    
    params[:sort] = sort_column
    params[:page] = sort_page
    params[:direction] = sort_direction
    @events = Event.sorty(params)
    @classifications ||= Classification.all
  end

  private

  def set_defaults

    case @range.to_sym
    when :last_24
      @cache = Cache.last_24
      
      @start_time = @now.yesterday
      @end_time = @now

    when :today
      @cache = Cache.today
      @start_time = @now.beginning_of_day
      @end_time = @now.end_of_day

    when :yesterday
      @cache = Cache.yesterday
      @start_time = (@now - 1.day).beginning_of_day
      @end_time = (@now - 1.day).end_of_day

    when :week
      @cache = DailyCache.this_week
      @start_time = @now.beginning_of_week
      @end_time = @now.end_of_week

    when :last_week
      @cache = DailyCache.last_week
      @start_time = (@now - 1.week).beginning_of_week
      @end_time = (@now - 1.week).end_of_week

    when :month
      @cache = DailyCache.this_month
      @start_time = @now.beginning_of_month
      @end_time = @now.end_of_month

    when :last_month
      @cache = DailyCache.last_month
      @start_time = (@now - 2.months).beginning_of_month
      @end_time = (@now - 2.months).end_of_month

    when :quarter
      @cache = DailyCache.this_quarter
      @start_time = @now.beginning_of_quarter
      @end_time = @now.end_of_quarter

    when :year
      @cache = DailyCache.this_year
      @start_time = @now.beginning_of_year
      @end_time = @now.end_of_year

    else
      @cache = Cache.today
      @start_time = @now.beginning_of_day
      @end_time = @now.end_of_day
    end

  end

  def sort_column
    return :timestamp unless params.has_key?(:sort)
    return params[:sort].to_sym if Event::SORT.has_key?(params[:sort].to_sym)
    :timestamp
  end
  
  def sort_direction
    %w[asc desc].include?(params[:direction].to_s) ? params[:direction].to_sym : :desc
  end

  def sort_page
    params[:page].to_i
  end

end
