module UsersHelper
  
  def get_gravatar_uri(email)
    # get the email from URL-parameters or what have you and make lowercase
   
    default_url = "#{root_url}images/default_avatar.png"

    return default_url unless @current_user && @current_user.gravatar

    return default_url unless email

    email_address = email.downcase
    # create the md5 hash
    hash = Digest::MD5.hexdigest(email_address)
    "https://gravatar.com/avatar/#{hash}.png?s=256&d=#{CGI.escape(default_url)}"
  end
  
end
