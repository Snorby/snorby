class RegistrationsController < Devise::RegistrationsController
  include Devise::Controllers::InternalHelpers
  
  before_filter :require_administrative_privileges, :only => [:create]

  def new
    build_resource({})
    render_with_scope :new
  end

  def create

    build_resource

    if resource.save
      if params[:user][:avatar].blank?
        redirect_to edit_user_registration_path, :notice => "Successfully created user."
      else
        render :template => "users/registrations/crop"
      end
    else
      clean_up_passwords(resource)
      render_with_scope :new
    end

  end

  def update

    if resource.update_with_password(params[resource_name])
      
      if params[:user][:avatar].blank?
        
        resource.reprocess_avatar
        
        set_flash_message :notice, :updated
        redirect_to edit_user_registration_path
      else
        render :template => "users/registrations/crop"
      end
    else
      clean_up_passwords(resource)
      render_with_scope :edit
    end
  end

end
