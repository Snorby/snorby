class JobsController < ApplicationController

  before_filter :require_administrative_privileges

  def index
    @jobs = Snorby::Jobs.find.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @jobs }
    end
  end

  def show
    @job = Snorby::Jobs.find.get(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @job }
    end
  end

  def edit
    @job = Snorby::Jobs.find.get(params[:id])
  end

  def update
    @job = Snorby::Jobs.find.get(params[:id])

    respond_to do |format|
      if @job.update(params[:job])
        format.html { redirect_to(@job, :notice => 'Job was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @job.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @job = Snorby::Jobs.find.get(params[:id])
    @job.destroy

    respond_to do |format|
      format.html { redirect_to(jobs_url) }
      format.xml  { head :ok }
    end
  end
end
