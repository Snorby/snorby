class EventsController < ApplicationController
  
  def index
    @events = Event.all.paginate(:page => params[:page], :per_page => 20)
  end
  
  def last
    render :json => {:time => Event.last.timestamp}
  end
  
  def since
    @events = Event.to_json_since(params[:timestamp])
    render :json => @events.to_json
  end
  
end
