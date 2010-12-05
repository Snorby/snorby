class UsersController < ApplicationController

  before_filter :require_administrative_privileges, :only => [:index, :add, :new, :remove]
  
  def index
    @users = User.all.page(params[:page].to_i, :per_page => @current_user.per_page_count, :order => [:id.asc])
  end

  def new
    @user = User.new
  end
  
  def add
    @user = User.create(params[:user])
    if @user.save
      redirect_to users_path
    else
      render :action => 'new'
    end
  end
  
  def remove
    @user = User.get(params[:id])
    @user.destroy!
    redirect_to users_path, :notice => "Successfully Delete User"
  end

  def toggle_settings
    @user = User.get(params[:user_id])
    
    if @user.update(params[:user])
      render :json => {:success => 'User updated successfully.'}
    else
      render :json => {:error => 'Error while changing user attributes.'}
    end
    
  end

end
