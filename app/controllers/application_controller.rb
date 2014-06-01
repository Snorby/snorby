require 'dm-rails/middleware/identity_map'

class ApplicationController < ActionController::Base
  # use Rails::DataMapper::Middleware::IdentityMap
  protect_from_forgery

  before_filter :user_setup
  after_filter :set_timezone
  # before_filter :authenticate_user!
  
  protected

    def require_administrative_privileges
      return true if user_signed_in? && current_user.admin
      redirect_to root_path, :notice => 'Your do not have sufficent privledges to complete this action.'
    end

    def set_timezone

      if user_signed_in?
        if Time.respond_to?(:zone)
          Time.zone = current_user.timezone
        else
          Time.timezone = current_user.timezone
        end

        # DataMapper::Zone::Types.storage_zone = current_user.timezone
      end
    end

    def user_setup

      @snorby_url ||= root_url(:host => Snorby::CONFIG[:domain])

      User.snorby_url = @snorby_url

      if user_signed_in?

        set_timezone 

        if current_user.enabled
          User.current_user = current_user
        else
          sign_out current_user
          redirect_to login_path, :notice => 'Your account has be disabled. Please contact the administrator.'
        end

      else

        current_uri = request.env['PATH_INFO']
	baseuri = Snorby::CONFIG[:baseuri]
        routes = ["", "/", baseuri + "/users/login"]
	
        if current_uri && routes.include?(current_uri)
          redirect_to baseuri + '/users/login' unless current_uri == baseuri + "/users/login"
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
