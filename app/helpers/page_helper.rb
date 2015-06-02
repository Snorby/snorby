module PageHelper

  def time_range_title(type)

    title = case type.to_sym
    when :last_24
      %{
        #{@now.yesterday.strftime('%D %H:%M')}
        -
        #{@now.strftime('%D %H:%M')}
      }
    when :today
      "#{@now.strftime('%A, %B %d, %Y')}"
    when :yesterday
      "#{@now.yesterday.strftime('%A, %B %d, %Y')}"
    when :week
      %{
        #{@now.beginning_of_week.strftime('%D')}
        -
        #{@now.end_of_week.strftime('%D')}
      }
    when :last_week
      %{
        #{(@now - 1.week).beginning_of_week.strftime('%D')}
        -
        #{(@now - 1.week).end_of_week.strftime('%D')}
      }
    when :month
      "#{@now.beginning_of_month.strftime('%B')}"
    when :last_month
      "#{(@now - 1.month).beginning_of_month.strftime('%B')}"
    when :quarter
      %{
        #{@now.beginning_of_quarter.strftime('%B %Y')}
        -
        #{@now.end_of_quarter.strftime('%B %Y')}
      }
    when :last_quarter
      # ...
    when :year
      "#{@now.strftime('%Y')}"
    when :last_year
     "#{(@now - 1.year).strftime('%Y')}" 
    else
      ""
    end

    title
  end

end
