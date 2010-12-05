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
    @notification = Notification.create(params[:notification])
    
    if params[:use_ip_src]
      @notification.ip_src = params[:notification][:ip_src]
    else
      @notification.ip_src = nil
    end
    
    if params[:use_ip_dst]
      @notification.ip_dst = params[:notification][:ip_dst]
    else
      @notification.ip_dst = nil
    end
    
    @notification.user = @current_user
    
    @notification.save
    
    respond_to do |format|
      format.html { render :layout => false }
      format.js
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
      format.html { redirect_to(notifications_url, :notice => 'Notification removed successfully.') }
      format.xml  { head :ok }
    end
  end
end
