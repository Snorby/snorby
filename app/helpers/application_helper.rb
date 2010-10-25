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
      menu = content_tag(:ul, capture(&block), :id => 'title-menu')
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

  def counter_box(data)
    "<a class='spch-bub-inside' href='#'><span class='point'></span><em>#{data}</em></a>".html_safe
  end

  def pager(collection, path)
    %{
      <div class='pager'>
        #{collection.pager.to_html("#{path}", :size => 9)}
      </div>
    }.html_safe
  end

end
