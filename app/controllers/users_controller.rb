class UsersController < ApplicationController

  before_filter :require_administrative_privileges, :only => [:index]
  
  def index
    
  end

end
