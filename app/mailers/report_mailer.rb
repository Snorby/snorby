class ReportMailer < ActionMailer::Base
  
  def daily_report
    @emails = []
    User.all.each { |user| @emails << "#{user.name} <#{user.email}>" }
    report = Snorby::Report.build_report('yesterday')
    attachments["snorby-daily-report.pdf"] = report[:pdf]
    mail(:to => @emails, :from => (Setting.email? ? Setting.find(:email) : "snorby@snorby.org"), :subject => "Snorby Daily Report: #{report[:start_time].strftime('%A, %B %d, %Y')}")
  end

  def weekly_report
    @emails = []
    User.all.each { |user| @emails << "#{user.name} <#{user.email}>" }
    report = Snorby::Report.build_report('last_week')
    attachments["snorby-weekly-report.pdf"] = report[:pdf]
    mail(:to => @emails, :from => (Setting.email? ? Setting.find(:email) : "snorby@snorby.org"), :subject => "Snorby Weekly Report: #{report[:start_time].strftime('%A, %B %d, %Y %I:%M %p')} - #{report[:end_time].strftime('%A, %B %d, %Y %I:%M %p')}")
  end
  
  def monthly_report
    @emails = []
    User.all.each { |user| @emails << "#{user.name} <#{user.email}>" }
    report = Snorby::Report.build_report('last_month')
    attachments["snorby-monthly-report.pdf"] = report[:pdf]
    mail(:to => @emails, :from => (Setting.email? ? Setting.find(:email) : "snorby@snorby.org"), :subject => "Snorby Monthly Report: #{report[:start_time].strftime('%A, %B %d, %Y %I:%M %p')} - #{report[:end_time].strftime('%A, %B %d, %Y %I:%M %p')}")
  end

end
