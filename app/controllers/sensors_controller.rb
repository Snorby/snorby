class SensorsController < ApplicationController

  before_filter :require_administrative_privileges, :except => [:index]

  def index
    @sensors = Sensor.all.page(params[:page].to_i, :per_page => 25, :order => [:name.desc])
  end

end
