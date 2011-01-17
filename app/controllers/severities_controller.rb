class SeveritiesController < ApplicationController

  before_filter :require_administrative_privileges

  def index
    @severities = Severity.all.page(params[:page].to_i, :per_page => @current_user.per_page_count, :order => [:id.asc])
  end

  def new
    @severity = Severity.new
  end

  def create
    @severity = Severity.create(params[:severity])
    if @severity.save
      redirect_to severities_path, :notice => 'Severity Created Successfully.'
    else
      render :action => 'new', :notice => 'Error: Unable To Create Record.'
    end
  end

  def update
    @severity = Severity.get(params[:id])
    if @severity.update(params[:severity])
      redirect_to severities_path, :notice => 'Severity Updated Successfully.'
    else
      render :action => 'edit', :notice => 'Error: Unable To Save Record.'
    end
  end

  def edit
    @severity = Severity.get(params[:id])
  end

  def destroy
    @severity = Severity.get(params[:id])
    @severity.destroy
    redirect_to severities_path, :notice => 'Severity Removed Successfully.'
  end

end
