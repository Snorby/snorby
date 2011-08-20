require 'dm-rails/middleware/identity_map'

class ApplicationController < ActionController::Base
  use Rails::DataMapper::Middleware::IdentityMap
  protect_from_forgery

  helper_method :check_for_demo_user

  before_filter :authenticate_user!
  before_filter :user_setup
  
  protected

    def require_administrative_privileges
      return true if user_signed_in? && current_user.admin
      redirect_to root_path
    end

    def check_for_demo_user
      redirect_to :back, :notice => 'The Demo Account cannot modify system settings.' if @current_user.demo?
    end

    def user_setup
      if user_signed_in?
        if current_user.enabled
          User.current_user = current_user
        else
          sign_out current_user
          redirect_to login_path, :notice => 'Your account has be disabled. Please contact the administrator.'
        end
      end
    end

end
