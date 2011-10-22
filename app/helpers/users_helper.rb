module UsersHelper
  
  def get_gravatar_uri(email)
    # get the email from URL-parameters or what have you and make lowercase
    email_address = email.downcase

    # create the md5 hash
    hash = Digest::MD5.hexdigest(email_address)

    # compile URL which can be used in <img src="RIGHT_HERE"...
    image_src = "http://www.gravatar.com/avatar/#{hash}"
  end
  
end
