class PageController < ApplicationController

  def dashboard
  end
  
  def search
  end
  
  def results
    @events = Event.search(params[:search]).page(params[:page].to_i, :per_page => @current_user.per_page_count, :order => [:timestamp.desc])
  end

end
