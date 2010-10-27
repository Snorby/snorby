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
    show_title(header)
    title_header = content_tag(:div, header, :id => 'title-header', :class => 'grid_6')
    if block_given?
      menu = content_tag(:ul, "<li>&nbsp;</li>#{capture(&block)}<li>&nbsp;</li>".html_safe, :id => 'title-menu')
      menu_holder = content_tag(:ul, menu, :id => 'title-menu-holder', :class => 'grid_6')
      html = title_header + menu_holder
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

  def pager(collection, path)
    %{<div class='pager'>#{collection.pager.to_html("#{path}", :size => 9)}</div>}.html_safe
  end

  def drop_down_for(name, icon_path, id, &block)
    html = link_to "#{image_tag(icon_path)} #{name}".html_safe, '#', :class => 'has_dropdown', :id => "#{id}"
    if block_given?
      html += content_tag(:dl, "#{capture(&block)}".html_safe, :id => "#{id}", :class => 'drop-down-menu', :style => 'display:none;')
    end
    "<li>#{html}</li>".html_safe
  end

  def drop_down_item(name, path='#', image_path=nil, options={})
    image = image_path ? "#{image_tag(image_path)} " : ""
    content_tag(:dd, "#{link_to "#{image}#{name}".html_safe, path, options}".html_safe)
  end

  #
  # Menu Item
  # 
  # @param [String] name Menu Item Name
  # @param [String] path Men Item Path
  # @param [String] image_path Menu Item Image Path
  # @param [Hash] options Options to padd to content_tag
  # 
  # @return [String] HTMl Menu Item
  # 
  def menu_item(name, path='#', image_path=nil, options={})
    image = image_path ? "#{image_tag(image_path)} " : ""
    content_tag(:li, "#{link_to "#{image}#{name}".html_safe, path, options}".html_safe)
  end

end