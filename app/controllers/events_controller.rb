class EventsController < ApplicationController
  respond_to :html, :xml, :json, :js, :csv

  def index
    @events = Event.all(:classification_id => nil).page(params[:page].to_i, :per_page => @current_user.per_page_count, :order => [:timestamp.desc])
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
      format.html {render :layout => false}
      format.js
      format.pdf do
        render :pdf => "Event:#{@event.id}", :template => "events/show.pdf.erb", :layout => 'pdf.html.erb', :stylesheets => ["pdf"]
      end
      format.csv { render :json => @event.to_csv }
      format.json { render :json => @event.in_json }
    end
  end
  
  def create_mass_action
    
  end

  def mass_action
    
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
    @events = Event.find_by_ids(params[:events])
    @classification = Classification.get(params[:classification].to_i)

    @events.each do |event|
      next unless event
      
      old_classification = event.classification || false

      if @classification.blank?
        event.classification = nil
      else
        event.classification = @classification
      end

      if event.save
        @classification.up(:events_count) if @classification
        old_classification.down(:events_count) if old_classification
      else
        Rails.logger.info "ERROR: #{event.errors.inspect}"
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
    if Setting.lookups?
      @lookup = Snorby::Lookup.new(params[:address])
      render :layout => false
    else
      render :text => '<div id="note-box">This feature has be disabled</div>'.html_safe, :notice => 'This feature has be disabled'
    end
  end
  
  def activity
    @user = User.get(params[:user_id])
    @events = @user.events.page(params[:page].to_i, :per_page => @current_user.per_page_count, :order => [:timestamp.desc])
    @classifications ||= Classification.all
  end
  
  def hotkey
    @classifications ||= Classification.all
    respond_to do |format|
      format.html {render :layout => false}
      format.js
    end
  end

end
