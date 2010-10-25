class EventsController < ApplicationController
  respond_to :html, :xml, :json, :js
  
  def index
    @events = Event.all(:classification_id => 0).page(params[:page].to_i, :per_page => 25, :order => [:timestamp.desc])
  end
  
  def queue
    @events ||= current_user.events.paginate(:page => params[:page], :per_page => 25)
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
  
  def favorite
    @event = Event.get(params[:sid], params[:cid])
    @event.toggle_favorite
    render :json => {}
  end
  
end
