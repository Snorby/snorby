class SensorsController < ApplicationController

  before_filter :require_administrative_privileges, :except => [:index]

  def index
    @sensors = Sensor.all.paginate(:page => params[:page], :per_page => 20)
  end

end
