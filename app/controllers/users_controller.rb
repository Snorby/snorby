class UsersController < ApplicationController

  before_filter :require_administrative_privileges, :only => [:index, :add, :new, :remove]
  
  def index
    @users = User.all.page(params[:page].to_i, :per_page => @current_user.per_page_count, :order => [:name.desc])
  end

  def new
    @user = User.new
  end
  
  def add
    @user = User.create(params[:user])
    if @user.save
      redirect_to users_path
    else
      render :action => 'add'
    end
  end
  
  def remove
    @user = User.get(params[:id])
    @user.destroy!
    redirect_to users_path, :notice => "Successfully Delete User"
  end

end
