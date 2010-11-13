class EventsController < ApplicationController
  respond_to :html, :xml, :json, :js, :csv

  def index
    @events = Event.all(:classification_id => 0).page(params[:page].to_i, :per_page => @current_user.per_page_count, :order => [:timestamp.desc])
    @classifications ||= Classification.all
  end

  def queue
    @events ||= current_user.events.page(params[:page].to_i, :per_page => @current_user.per_page_count, :order => [:timestamp.desc])
    @classifications ||= Classification.all
  end

  def show
    @event = Event.get(params['sid'], params['cid'])
    @notes = @event.notes.all.page(params[:page].to_i, :per_page => 5, :order => [:id.desc])
    respond_to do |format|
      format.html
      format.js
      format.pdf do
        render :pdf => "Event:#{@event.id}", :template => "events/show.pdf.erb", :layout => 'pdf.html.erb'
      end
      format.csv { render :json => @event.to_csv }
      format.json { render :json => @event.in_json }
    end
  end

  def export
    @events = Event.find_by_ids(params[:events])

    respond_to do |format|
      format.json { render :json => @events }
      format.xml { render :xml => @events }
      format.csv { render :json => @events.to_csv }
    end
  end

  def history
    @events = Event.all(:updated_by_id => @current_user.id).page(params[:page].to_i, :per_page => @current_user.per_page_count, :order => [:timestamp.desc])
    @classifications ||= Classification.all
  end

  def classify
    @events ||= Event.find_by_ids(params[:events])
    @classification ||= Classification.get(params[:classification])

    @events.each do |event|
      next unless event
      old_classification = event.classification

      if event.update!(:classification => @classification)
        @classification.up_counter(:events_count) if @classification
        old_classification.down_counter(:events_count) if old_classification
      end

    end

    render :layout => false, :status => 200
  end


  def mass_create_favorite
    @events ||= Event.find_by_ids(params[:events])
    @events.each { |event| event.create_favorite unless favorite? }
    render :json => {}
  end

  def mass_destroy_favorite
    @events ||= Event.find_by_ids(params[:events])
    @events.each { |event| event.destroy_favorite if favorite? }
    render :json => {}
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
