class EventsController < ApplicationController
  
  def index
    @events = Event.all.paginate(:page => params[:page], :per_page => 20)
  end
  
  def last
    render :json => {:time => Event.last.timestamp}
  end
  
  def since
    @events = Event.all(:timestamp.gt => params[:timestamp])
    if @events.blank?
      render :json => {}
    else
      render :json => { :events => @events.to_json(:include => [:signature, :ips]), :count => @events.size }
    end
  end
  
end
