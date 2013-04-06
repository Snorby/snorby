class SensorsController < ApplicationController

  before_filter :require_administrative_privileges, :except => [:index, :destroy]

  def agents
    @sensors ||= Sensor.all.page(params[:page].to_i, :per_page => @current_user.per_page_count, :order => [:sid.asc])
    respond_to do |format|
      format.html {render :layout => true}
      format.js { render :json => @sensors }
    end
  end

  def agent_list
    @agents ||= Sensor.all(:order => [:sid.asc])
    respond_to do |format|
      format.html {render :layout => true}
      format.json { render :json => @agents }
    end
  end

  def index
    @sensors ||= Sensor.all.page(params[:page].to_i, :per_page => @current_user.per_page_count, :order => [:sid.asc])
    
    respond_to do |format|
      format.html {render :layout => true}
      format.js
    end
  end

  def destroy
  	@sensor = Sensor.get(params[:id])
  	unless Snorby::Worker.running?
	   redirect_to :back, :flash => { :error => "The snorby working must be running in order to delete a sensor." }
	  end
  	if @sensor.present?
  		@sensor.update(:pending_delete => true)
  		Delayed::Job.enqueue(Snorby::Jobs::SensorDeleteJob.new(@sensor.sid), :priority => 1) if @sensor.save
  		redirect_to sensors_path, :flash => { :success => "The sensor will be destroyed shortly." }
  	else
  		redirect_to sensors_path, :flash => { :error => "There was an unknown error when attempting to delete the sensor" }
  	end
  end
  
  def update_name
    @sensor = Sensor.get(params[:id])
    @sensor.update!(:name => params[:name]) if @sensor
    render :text => @sensor.name
  end

end
