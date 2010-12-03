require 'dm-rails/middleware/identity_map'

class ApplicationController < ActionController::Base
  use Rails::DataMapper::Middleware::IdentityMap
  protect_from_forgery

  before_filter :authenticate_user!
  before_filter :timezone

  protected

    def require_administrative_privileges
      return true if user_signed_in? && current_user.admin
      redirect_to root_path
    end

    def timezone
      if user_signed_in?
        # if Time.respond_to?(:zone)
        #   Time.zone = current_user.timezone
        # else
        #   Time.timezone = current_user.timezone
        # end
        User.current_user = current_user
      end
    end

end
