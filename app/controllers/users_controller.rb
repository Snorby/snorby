class UsersController < ApplicationController

  before_filter :require_administrative_privileges, :only => [:index]
  
  def index
    @users = User.all.page(params[:page].to_i, :per_page => @current_user.per_page_count, :order => [:name.desc])
  end

end
