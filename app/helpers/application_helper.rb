module ApplicationHelper

  def title(header, &block)
    title_header = content_tag(:div, header, :id => 'title-header', :class => 'grid_8')
    if block_given?
      title_menu = content_tag(:ul, capture(&block), :id => 'title-menu', :class => 'grid_4')
      html = title_header + title_menu
    else
      html = title_header
    end 
    return content_tag(:div, html, :id => 'title')
  end

end
