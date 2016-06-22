class SessionsController < Devise::SessionsController
  layout 'login'

  def create
    resource = warden.authenticate!(:scope => :user,
    :recall => "sessions#failure")

    sign_in resource

    set_flash_message :notice, :signed_in
    redirect_to root_path
  end

  def failure
    respond_to do |format|
      format.html do
        set_flash_message :notice, :invalid
        redirect_to new_user_session_path
      end
    end
  end

  # DELETE /resource/sign_out
  def destroy
    respond_to do |format|
      format.html do
        set_flash_message :notice, :signed_out
        sign_out current_user
        redirect_to new_user_session_path
      end
    end
  end

end

