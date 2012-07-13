module UsersHelper
  
  def get_gravatar_uri(email)
    # get the email from URL-parameters or what have you and make lowercase
    email_address = email.downcase

    # create the md5 hash
    hash = Digest::MD5.hexdigest(email_address)
    default_url = "#{root_url}images/default_avatar.png"
    "http://gravatar.com/avatar/#{hash}.png?s=48&d=#{CGI.escape(default_url)}"
  end
  
end






