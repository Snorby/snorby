class SessionsController < Devise::SessionsController
  layout 'login'

  def create
    resource = warden.authenticate!(:scope => resource_name, 
    :recall => "sessions#failure")

    return sign_in_and_redirect(resource_name, resource)
  end
  
  def sign_in_and_redirect(resource_or_scope, resource=nil)
    scope = Devise::Mapping.find_scope!(resource_or_scope)
    resource ||= resource_or_scope
    sign_in(scope, resource) unless warden.user(scope) == resource

    return render :json => {
      :success => true, 
      :authenticity_token => form_authenticity_token, 
      :user => @current_user.in_json,
      :version => Snorby::VERSION,
      :redirect => stored_location_for(scope) || after_sign_in_path_for(resource)
    }
  end

  def failure
    return render:json => {:success => false, :errors => ["Login failed."]}
  end

  # DELETE /resource/sign_out
  def destroy
    redirect_path = after_sign_out_path_for(resource_name)
    signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
    set_flash_message :notice, :signed_out if signed_out && is_navigational_format?

    # We actually need to hardcode this as Rails default responder doesn't
    # support returning empty response on GET request
    respond_to do |format|
      format.html do
        redirect_to redirect_path
      end
      format.json { render :json => { status: "success", user: @current_user }}
    end
  end

end

