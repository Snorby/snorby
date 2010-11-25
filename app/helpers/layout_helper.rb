# These helper methods can be called in your template to set variables to be used in the layout
# This module should be included in all views globally,
# to do so you may need to add this line to your ApplicationController
#   helper :layout
module LayoutHelper

  def stylesheet(*args)
    content_for(:header) { stylesheet_link_tag(*args) }
  end

  def javascript(placement=false, *args)
    return content_for(placement.to_sym) { javascript_include_tag(*args) } if placement
    content_for(:header) { javascript_include_tag(*args) }
  end
  
  def show_title(title)
    content_for(:title) { "Snorby - #{title}" } if title
  end
  
end
