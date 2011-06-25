class PageController < ApplicationController

  def dashboard

    @range = params[:range].blank? ? 'today' : params[:range]

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

    @axis = @sensor_metrics.last[:range].join(',') if @sensor_metrics.last

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
    begin
      limit = params[:limit].to_i.zero? ? @current_user.per_page_count : params[:limit].to_i
      @events = Event.search(params[:search]).page(params[:page].to_i, :per_page => limit, :order => [:timestamp.desc])
      @classifications ||= Classification.all
    rescue ArgumentError
      redirect_to :back, :notice => 'Please double check you search parameters and make sure they are valid.'
    end
  end

  private

    def set_defaults

      case @range.to_sym
      when :today
        @cache = Cache.today
        @start_time = Time.now.beginning_of_day
        @end_time = Time.now.end_of_day

      when :yesterday
        @cache = Cache.yesterday
        @start_time = (Time.now - 1.day).beginning_of_day
        @end_time = (Time.now - 1.day).end_of_day

      when :week
        @cache = DailyCache.this_week
        @start_time = Time.now.beginning_of_week
        @end_time = Time.now.end_of_week

      when :last_week
        @cache = DailyCache.last_week
        @start_time = (Time.now - 1.week).beginning_of_week
        @end_time = (Time.now - 1.week).end_of_week

      when :month
        @cache = DailyCache.this_month
        @start_time = Time.now.beginning_of_month
        @end_time = Time.now.end_of_month

      when :last_month
        @cache = DailyCache.last_month
        @start_time = (Time.now - 2.months).beginning_of_month
        @end_time = (Time.now - 2.months).end_of_month

      when :quarter
        @cache = DailyCache.this_quarter
        @start_time = Time.now.beginning_of_quarter
        @end_time = Time.now.end_of_quarter

      when :year
        @cache = DailyCache.this_year
        @start_time = Time.now.beginning_of_year
        @end_time = Time.now.end_of_year

      else
        @cache = Cache.today
        @start_time = Time.now.beginning_of_day
        @end_time = Time.now.end_of_day
      end

    end

end