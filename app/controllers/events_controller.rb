class EventsController < ApplicationController
  respond_to :html, :xml, :json, :js
  
  def index
    @events = Event.all(:classification_id => 1).page(params[:page].to_i, :per_page => 25, :order => [:timestamp.desc])
  end
  
  def queue
    @events ||= current_user.events.page(params[:page].to_i, :per_page => 25, :order => [:timestamp.desc])
  end
  
  def show
    @event = Event.get(params['sid'], params['cid'])
    render :json => @event.in_json
  end
  
  def classify
    events = Event.find_by_ids(params[:events])
    events.each do |event| 
      event.update(:classification_id => params[:classification]) if event
    end
    redirect_to events_path, :notice => 'Event Classified Successfully'
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
  
  def lookup
    @lookup = Snorby::Lookup.new(params[:address])
    render :layout => false
  end
  
end
