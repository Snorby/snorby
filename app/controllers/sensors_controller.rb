class SensorsController < ApplicationController

  before_filter :require_administrative_privileges, :except => [:index]

  def index
    @sensors = Sensor.all.page(params[:page].to_i, :per_page => 25, :order => [:name.desc])
  end
  
  def update_name
    @sensor = Sensor.get(params[:id])
    @sensor.update!(:name => params[:name]) if @sensor
    render :text => @sensor.name
  end

end
