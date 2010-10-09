require 'dm-rails/middleware/identity_map'

class ApplicationController < ActionController::Base
  use Rails::DataMapper::Middleware::IdentityMap
  protect_from_forgery
  
  before_filter :authenticate_user!
  before_filter :timezone

  protected

    def timezone
      if user_signed_in?
        if Time.respond_to?(:zone)
          Time.zone = current_user.timezone
        else
          Time.timezone = current_user.timezone
        end
      end
    end

end
