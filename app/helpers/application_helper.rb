module ApplicationHelper

  def select_options(options, attributes={})
    select_options = ""
    options.each do |data|
      content = content_tag(:option, data.last, :value => data.first)
      content = content_tag(:option, data.last, :value => data.first, :selected => 'selected') if attributes[:selected].to_s == data.first.to_s
      select_options += content
    end
    select_options = "<option value=''></option>#{select_options}" if attributes[:include_blank]
    select_options.html_safe
  end

  def dropdown_select_tag(collection, value, include_blank=false, custom=[])
    options = include_blank ? "<option value=''></option>" : ""
    custom.collect { |x| options += x }
    collection.collect { |x| options += "<option value='#{x.send(value.to_sym)}'>#{x.name}</option>" }
    options.html_safe
  end

  def pretty_time(time)
    time.strftime('%A, %B %d, %Y %I:%M %p')
  end

  def format_note_body(text)
    return text.sub(/(\B\@[a-zA-Z0-9_%]*\b)/, '<strong>\1</strong>').html_safe
  end

  #
  # Title
  #
  # @param [String] header
  # @param [Block] yield for title-menu items
  #
  # @return [String] title html
  #
  def title(header, title=nil, &block)
    show_title(title ? title : header)
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

  #
  # Pager
  #
  # Setup pager and return helper
  # html for view display
  #
  # @param [String] collection
  # @param [String] parent pager path
  # @param [Boolean] fade_content
  #
  def pager(collection, path, fade_content=true)
    if fade_content
      %{<div class='pager main'>#{collection.pager.to_html("#{path}", :size => 9)}</div>}.html_safe
    else
      %{<div class='pager notes-pager'>#{collection.pager.to_html("#{path}", :size => 9)}</div>}.html_safe
    end
  end

  def drop_down_for(name, icon_path, id, &block)
    html = link_to "#{image_tag(icon_path, :size => '16x16')} #{name}".html_safe, '#', :class => 'has_dropdown right-more', :id => "#{id}"
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

  def snorby_box(title, normal_size=true, &block)
    html = content_tag(:div, title, :id => 'box-title')
    
    if normal_size
      html += content_tag(:div, capture(&block), :id => 'box-content')
    else
      html += content_tag(:div, capture(&block), :id => 'box-content-small')
    end
    
    html += content_tag(:div, nil, :id => 'box-footer')
    content_tag(:div, html, :id => 'snorby-box')
  end

  def form_actions(&block)
    content_tag(:div, capture(&block), :id => 'form-actions')
  end

  def button(name, options={})
    # <span class="success" style="display:none">✓ saved</span>
    options[:class] = options[:class] ? options[:class] += " default" : "default"
    content_tag(:button, "<span>#{name}</span>".html_safe, options)
  end

  def css_chart(percentage)
    html = content_tag(:div, "<span>#{percentage}%</span>".html_safe, :style => "width: #{percentage}%")
    content_tag(:div, html, :class => 'progress-container')
  end

  def worker_status(show_image=false)

    if Snorby::Jobs.sensor_cache? && Snorby::Jobs.daily_cache?
      return content_tag(:span, "OK", :class => 'status ok add_tipsy', :title => 'Success: Everything Looks Good!')
      #return image_tag('icons/active.png', :class => 'add_tipsy', :title => 'Success: Everything Looks Good!')
    elsif Snorby::Jobs.sensor_cache?
      return content_tag(:span, "WARNING", :class => 'status warning add_tipsy', :title => 'Warning: The Daily Cache Job Is Not Running...')
      #return image_tag('icons/job-fail.png', :class => 'add_tipsy', :title => 'Warning: The Daily Cache Job Is Not In Running...')
    elsif Snorby::Jobs.daily_cache?
      return content_tag(:span, "WARNING", :class => 'status warning add_tipsy', :title => 'Warning: The Sensor Cache Job Is Not Running...')
      #return image_tag('icons/job-fail.png', :class => 'add_tipsy', :title => 'Warning: The Sensor Cache Job Is Not In Running...')
    else
      return content_tag(:span, "FAIL", :class => 'status fail add_tipsy', :title => 'ERROR: Both Cache Jobs Are Not Running...')
      #return image_tag('icons/dead.png', :class => 'add_tipsy', :title => 'ERROR: Both Cache Jobs Are Not Running...')
    end

  end

  #
  # Percentage Helper
  # 
  # Used for generating customized 
  # percentages used in the view and pdf
  # reports. This method will protect
  # impossible percentages.
  #
  # @param [Integer] count Count from total
  # @param [Integer] total The total count
  # @param [Integer] round Rounding Option
  # 
  # @return [Integer] percentage
  # 
  def percentage_for(count, total, round=2)
    begin
      percentage = ((count.to_f / total.to_f) * 100).round(round)
      return 100.round(round) if percentage.round > 100
      percentage
    rescue FloatDomainError
      0
    end
  end

end
