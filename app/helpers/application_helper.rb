module ApplicationHelper

  #
  # Title
  # 
  # @param [String] header
  # @param [Block] yield for title-menu items
  # 
  # @return [String] title html
  # 
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

  def sortable(column, title = nil)
    title ||= column.titleize
    css_class = column == sort_column ? "current #{sort_direction}" : nil
    direction = column == sort_column && sort_direction == "asc" ? "desc" : "asc"
    link_to title, {:sort => column, :direction => direction}, {:class => css_class}
  end

end
