require 'dm-rails/middleware/identity_map'

class ApplicationController < ActionController::Base
  use Rails::DataMapper::Middleware::IdentityMap
  protect_from_forgery

  helper_method :check_for_demo_user
  before_filter :user_setup
  # before_filter :authenticate_user!
  
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
      else

        current_uri = request.env['PATH_INFO']
        routes = ["", "/", "/users/login"]

        if current_uri && routes.include?(current_uri)
          redirect_to '/users/login' unless current_uri == "/users/login"
        else
          authenticate_user!
        end
      end

      # if Time.respond_to?(:zone)
      #   Time.zone = current_user.timezone
      # else
      #   Time.timezone = current_user.timezone
      # end
    end

end
