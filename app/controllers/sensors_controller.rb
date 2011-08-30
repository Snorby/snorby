class SensorsController < ApplicationController

  before_filter :require_administrative_privileges, :except => [:index, :update_name]
  
  def index
    @sensors ||= Sensor.all.page(params[:page].to_i, :per_page => @current_user.per_page_count, :order => [:sid.asc])
  end
  
  def update_name
    @sensor = Sensor.get(params[:id])
    @sensor.update!(:name => params[:name]) if @sensor
    render :text => @sensor.name
  end

  def options
    @sensor = Sensor.get(params[:id])

    respond_to do |format|
      format.html {render :layout => false}
      format.js
    end
  end

  def update
    @sensor = Sensor.get(params[:id])

    respond_to do |format|
      if @sensor.update(params[:sensor])
        format.html { redirect_to(sensors_url, :notice => 'Sensor options successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @sensor.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @sensor = Sensor.get(params[:id])
    @sensor.destroy!

    respond_to do |format|
      format.html { redirect_to(sensors_url) }
      format.xml  { head :ok }
    end
  end

end
