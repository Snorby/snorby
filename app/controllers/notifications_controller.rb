class NotificationsController < ApplicationController

  def index
    @notifications = Notification.all.page(params[:page].to_i, :per_page => @current_user.per_page_count, :order => [:created_at])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @notifications }
    end
  end

  def show
    @notification = Notification.get(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @notification }
    end
  end

  def new
    @notification = Notification.new
    @event = Event.get(params[:sid], params[:cid])
    render :layout => false
  end

  def edit
    @notification = Notification.get(params[:id])
  end

  def create
    @notification = Notification.new(params[:notification])
    @notification.ip_src = nil if params[:use_ip_src].to_i.zero?
    @notification.ip_dst = nil if params[:use_ip_src].to_i.zero?
    
    if @notification.save
      redirect_to events_path, :notice => 'Notification was successfully created.'
    else
      #redirect_to events_path, :notice => 'Notification was successfully created.'
    end
    
  end

  def update
    @notification = Notification.get(params[:id])

    respond_to do |format|
      if @notification.update(params[:notification])
        format.html { redirect_to(@notification, :notice => 'Notification was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @notification.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @notification = Notification.get(params[:id])
    @notification.destroy

    respond_to do |format|
      format.html { redirect_to(notifications_url) }
      format.xml  { head :ok }
    end
  end
end
