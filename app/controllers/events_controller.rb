class EventsController < ApplicationController
  respond_to :html, :xml, :json, :js
  
  def index
    @events = Event.all(:classification_id => 0).page(params[:page].to_i, :per_page => 25, :order => [:timestamp.desc])
    @classifications ||= Classification.all
  end
  
  def queue
    @events ||= current_user.events.page(params[:page].to_i, :per_page => 25, :order => [:timestamp.desc])
    @classifications ||= Classification.all
  end
  
  def show
    @event = Event.get(params['sid'], params['cid'])
    respond_to do |format|
      format.html
      format.js
      format.json { render :json => @event.in_json }
    end
  end
  
  def history
    @events = Event.all(:updated_by_id => @current_user.id).page(params[:page].to_i, :per_page => 25, :order => [:timestamp.desc])
    @classifications ||= Classification.all
  end
  
  def classify
    @events = Event.find_by_ids(params[:events])
    
    @events.each do |event|
      event.update(:classification_id => params[:classification])
    end
    
    render :layout => false, :status => 200
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
