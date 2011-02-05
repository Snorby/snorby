class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :authenticate_user!
  before_filter :user_setup
  
  protected

    def require_administrative_privileges
      return true if user_signed_in? && current_user.admin
      redirect_to root_path
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
      # if Time.respond_to?(:zone)
      #   Time.zone = current_user.timezone
      # else
      #   Time.timezone = current_user.timezone
      # end
    end

end
