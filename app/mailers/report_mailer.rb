class ReportMailer < ActionMailer::Base

  def daily_report(email, timezone="UTC")
    report = Snorby::Report.build_report('yesterday', timezone)
    attachments["snorby-daily-report.pdf"] = report[:pdf]

    # File.open("/Users/mephux/Desktop/test-#{timezone}.pdf", "wb") do |file|
      # file << report[:pdf]
    # end

    mail(:to => email,
         :from => (Setting.email? ? Setting.find(:email) : "snorby@example.com"),
         :subject => "Snorby Daily Report: #{report[:start_time].strftime('%A, %B %d, %Y')}")
  end

  def weekly_report(email, timezone="UTC")
    report = Snorby::Report.build_report('last_week', timezone)
    attachments["snorby-weekly-report.pdf"] = report[:pdf]

    # File.open("/Users/jandre/Desktop/test-#{timezone}.pdf", "wb") do |file|
      # file << report[:pdf]
    # end

    mail(:to => email, 
         :from => (Setting.email? ? Setting.find(:email) : "snorby@example.com"), 
         :subject => "Snorby Weekly Report: #{report[:start_time].strftime('%A, %B %d, %Y %I:%M %p')} - #{report[:end_time].strftime('%A, %B %d, %Y %I:%M %p')}")
  end

  def monthly_report(email, timezone="UTC")
    report = Snorby::Report.build_report('last_month', timezone)
    attachments["snorby-monthly-report.pdf"] = report[:pdf]
    mail(:to => email, 
         :from => (Setting.email? ? Setting.find(:email) : "snorby@example.com"), 
         :subject => "Snorby Monthly Report: #{report[:start_time].strftime('%A, %B %d, %Y %I:%M %p')} - #{report[:end_time].strftime('%A, %B %d, %Y %I:%M %p')}")
  end

  def update_report(email, data, timezone="UTC")
    @data = data
    total_event_count = data.map(&:event_count).sum
    p @data
    mail(:to => email,
      :from => (Setting.email? ? Setting.find(:email) : "snorby@example.com"),
      :subject => "Snorby Event Report [Count: #{total_event_count}] #{@data.first.ran_at.strftime('%D %H:%M:%S %Z')} - #{(@data.first.ran_at + 30.minutes).strftime('%D %H:%M:%S %Z')}")
  end

end
