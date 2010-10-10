class SensorsController < ApplicationController

  def index
    @sensors = Sensor.all.paginate(:page => params[:page], :per_page => 20)
  end

end
