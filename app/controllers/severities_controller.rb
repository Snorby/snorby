class SeveritiesController < ApplicationController

  before_filter :require_administrative_privileges

  def index
    @severities = Severity.all.page(params[:page].to_i, :per_page => 25)
  end

  def new
    @severity = Severity.new
  end
  
  def create
    @severity = Severity.create(params[:severity])
    if @severity.save
      redirect_to severities_path
    else
      render :action => 'new'
    end
  end

  def update
    @severity = Severity.get(params[:id])
    if @severity.update(params[:severity])
      redirect_to severities_path
    else
    end
  end

  def edit
    @severity = Severity.get(params[:id])
  end

  def destroy
    @severity = Severity.get(params[:id])
  end

end