class EventsController < ApplicationController
  
  helper_method :sort_column, :sort_direction
  
  def index
    @severities = Severity.all
    @events = Event.all(:order => [:timestamp.desc], :links => [:ip]).paginate(:page => params[:page], :per_page => 25)
  end
  
  def show
    @event = Event.get(params['sid'], params['cid'])
    render :json => @event.in_json
  end
  
  def last
    render :json => {:time => Event.last.timestamp}
  end
  
  def since
    @events = Event.to_json_since(params[:timestamp])
    render :json => @events.to_json
  end
  
  private
  
  def sort_column
    Event.properties.map(&:name).map(&:to_s).include?(params[:sort]) ? params[:sort] : "timestamp"
  end
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end
  
end
