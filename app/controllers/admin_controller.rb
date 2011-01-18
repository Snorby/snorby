class AdminController < ApplicationController

  before_filter :require_administrative_privileges
  before_filter :check_for_demo_user, :only => [:new, :create, :edit, :update, :destroy]

  def check_for_demo_user
    redirect_to :back, :notice => 'The Demo Account cannot modify system settings.' if @current_user.demo?
  end

  def settings 
    # ...
  end

  def severity
    @severity = Severity.first(:sig_id => params[:id])
    if @severity.update(params[:severity])
    else
    end
  end

end
