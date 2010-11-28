module OutsideRails
  
  module Stuff
    include Rails.application.routes.url_helpers # brings ActionDispatch::Routing::UrlFor
    include ActionView::Helpers::TagHelper
    
    def initializer(path)
      
    end
    
  end
  
end