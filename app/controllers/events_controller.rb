class EventsController < ApplicationController
  respond_to :html, :xml, :json, :js, :csv

  helper_method :sort_column, :sort_direction

  def index
    params[:sort] = sort_column
    params[:direction] = sort_direction

    @events = Event.sorty(params)
    @classifications ||= Classification.all

    respond_to do |format|
      format.html {render :layout => true}
      format.js
      format.json {render :json => {
        :events => @events.map(&:detailed_json),
        :classifications => @classifications,
        :pagination => {
          :total => @events.pager.total,
          :per_page => @events.pager.per_page,
          :current_page => @events.pager.current_page,
          :previous_page => @events.pager.previous_page,
          :next_page => @events.pager.next_page,
          :total_pages => @events.pager.total_pages
        }
      }}
    end
  end

  def sessions
    @session_view = true

    params[:sort] = sort_column 
    params[:direction] = sort_direction

    sql = %{
      select e.sid, e.cid, e.signature,
      e.classification_id, e.users_count,
      e.notes_count, e.timestamp, e.user_id,
      a.number_of_events from aggregated_events a
      inner join event e on a.event_id = e.id
    }

    sort = if [:sid,:signature,:timestamp].include?(params[:sort])
      "e.#{params[:sort]}"
    elsif params[:sort] == :sig_priority
      sql += "inner join signature s on e.signature = s.sig_id "
      "s.#{params[:sort]}"
    else
      "a.#{params[:sort]}"
    end

    sql += "order by #{sort} #{params[:direction]} limit ? offset ?"

    @events = Event.sorty(params, [sql], "select count(*) from aggregated_events;")

    @classifications ||= Classification.all

    respond_to do |format|
      format.html {render :layout => true}
      format.js
      format.json {render :json => {
        :events => @events.map(&:detailed_json),
        :classifications => @classifications,
        :pagination => {
          :total => @events.pager.total,
          :per_page => @events.pager.per_page,
          :current_page => @events.pager.current_page,
          :previous_page => @events.pager.previous_page,
          :next_page => @events.pager.next_page,
          :total_pages => @events.pager.total_pages
        }
      }}
    end
  end

  def queue
    params[:sort] = sort_column
    params[:direction] = sort_direction
    params[:classification_all] = true
    params[:user_events] = true

    @events ||= current_user.events.sorty(params)
    @classifications ||= Classification.all

    respond_to do |format|
      format.html {render :layout => true}
      format.js
      format.json {render :json => {
        :events => @events.map(&:detailed_json),
        :classifications => @classifications,
        :pagination => {
          :total => @events.pager.total,
          :per_page => @events.pager.per_page,
          :current_page => @events.pager.current_page,
          :previous_page => @events.pager.previous_page,
          :next_page => @events.pager.next_page,
          :total_pages => @events.pager.total_pages
        }
      }}
    end

  end

  def request_packet_capture
    @event = Event.get(params['sid'], params['cid'])
    @packet = @event.packet_capture(params)
    respond_to do |format|
      format.html {render :layout => false}
      format.js
    end
  end

  def rule
    @event = Event.get(params['sid'], params['cid'])
    @event.rule ? @rule = @event.rule : @rule = 'No rule found for this event.'

    respond_to do |format|
      format.html { render :layout => false }
    end
  end

  def show
    if params.has_key?(:sessions)
      @session_view = true
    end

    @event = Event.get(params['sid'], params['cid'])
    @lookups ||= Lookup.all

    @notes = @event.notes.all.page(params[:page].to_i,
                                   :per_page => 5, :order => [:id.desc])

    respond_to do |format|
      format.html {render :layout => false}
      format.js

      format.pdf do
        render :pdf => "Event:#{@event.id}",
               :template => "events/show.pdf.erb",
               :layout => 'pdf.html.erb', :stylesheets => ["pdf"]
      end

      format.xml { render :xml => @event.in_xml }
      format.csv { render :text => @event.to_csv }
      format.json { render :json => {
        :event => @event.in_json,
        :notes => @notes.map(&:in_json) 
      }}
    end
  end

  def view
    @events = Event.all(:sid => params['sid'],
    :cid => params['cid']).page(params[:page].to_i,
    :per_page => @current_user.per_page_count, :order => [:timestamp.desc])

    @classifications ||= Classification.all
  end

  def create_email
    @event = Event.get(params[:sid], params[:cid])
    render :layout => false
  end

  def email
    Delayed::Job.enqueue(Snorby::Jobs::EventMailerJob.new(params[:sid],
    params[:cid], params[:email]))

    respond_to do |format|
      format.html { render :layout => false }
      format.js
    end
  end

  def create_mass_action
    @event = Event.get(params[:sid], params[:cid])
    render :layout => false
  end

  def mass_action
    options = {}

    params[:reclassify] ? (reclassify = true) : (reclassify = false)

    if params.has_key?(:sensor_ids)
      if params[:sensor_ids].is_a?(Array)

        params[:sensor_ids].each do |id|
          options.merge!({
            :"#{id}" => {
              :column => :sid,
              :operator => :is,
              :value => id.to_i,
              :enabled => true
            }
          })
        end
      end
    end

    unless params[:reclassify]
      options.merge!({
        :classification => {
          :column => :classification,
          :operator => :isnull,
          :value => ''
        }
      })
    end

    if params[:use_sig_id]
      options.merge!({
        :"sigid" => {
          :column => :signature,
          :operator => :is,
          :value => params[:sig_id].to_i,
          :enabled => true
        }
      })
    end

    if params[:use_ip_src]
      options.merge!({
        :"use_ip_src" => {
          :column => :source_ip,
          :operator => :is,
          :value => IPAddr.new(params[:ip_src].to_i,Socket::AF_INET),
          :enabled => true
        }
      })
    end

    if params[:use_ip_dst]
      options.merge!({
        :"use_ip_dst" => {
          :column => :destination_ip,
          :operator => :is,
          :value => IPAddr.new(params[:ip_dst].to_i,Socket::AF_INET),
          :enabled => true
        }
      })
    end

    if options.empty?
      render :js => "flash_message.push({type: 'error', message: 'Sorry," +
        " Insufficient classification parameters submitted...'});flash();"
    else

      sql = Snorby::Search.build("true", true, options)
      ids = Event.get_collection_id_string(sql)

      if params[:jobqueue]
        Delayed::Job.enqueue(Snorby::Jobs::MassClassification.new(ids, params[:classification_id], User.current_user.id))
      else
        Event.update_classification(ids, params[:classification_id], User.current_user.id)
      end

      respond_to do |format|
        format.html { render :layout => false }
        format.js
      end
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
    @events = Event.all(:user_id => @current_user.id).page(params[:page].to_i,
    :per_page => @current_user.per_page_count, :order => [:timestamp.desc])
    @classifications ||= Classification.all
  end

  def classify
    if params[:events]
      Event.update_classification(params[:events], params[:classification].to_i, User.current_user.id)
    end

    respond_to do |format|
      format.html { render :layout => false, :status => 200 }
      format.json { render :json => { :status => 'success' }}
    end
  end

  def classify_sessions
    if params[:events]
      Event.update_classification_by_session(params[:events], params[:classification].to_i, User.current_user.id)
    end

    respond_to do |format|
      format.html { render :layout => false, :status => 200 }
      format.json { render :json => { :status => 'success' }}
    end
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
    render :json => { :time => Event.last_event_timestamp }
  end

  def since
    @events = Event.to_json_since(params[:timestamp])
    render :json => @events.to_json
  end

  def favorite
    @event = Event.get(params[:sid], params[:cid])
    @event.toggle_favorite
    render :json => { :favorite => @event.favorite? }
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
    @user = @current_user unless @user

    @events = @user.events.page(params[:page].to_i, :per_page => @current_user.per_page_count,
              :order => [:timestamp.desc])

    @classifications ||= Classification.all
  end

  def hotkey
    @classifications ||= Classification.all
    respond_to do |format|
      format.html {render :layout => false}
      format.js
    end
  end

  def packet_capture
    @event = Event.get(params[:sid], params[:cid])
    render :layout => false
  end

  private

  def sort_column

    if params.has_key?(:sort)
      return params[:sort].to_sym if Event::SORT.has_key?(params[:sort].to_sym) or [:signature].include?(params[:sort].to_sym)
    end

    :timestamp
  end

  def sort_direction
    %w[asc desc].include?(params[:direction].to_s) ? params[:direction].to_sym : :desc
  end

end
