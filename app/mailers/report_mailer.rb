class ReportMailer < ActionMailer::Base
  
  default :from => Setting.from? ? Setting.from : "snorby@snorby.org"
  
  def daily_report
    @emails = User.all.collect { |user| "#{user.name} <#{user.email}>" }.join(',')
    report = Snorby::Report.build_report('yesterday')
    attachments["snorby-daily-report.pdf"] = report[:pdf]
    mail(:to => @emails, :subject => "Snorby Daily Report: #{report[:start_time]} - #{report[:end_time]}")
  end

  def weekly_report
    @emails = User.all.collect { |user| "#{user.name} <#{user.email}>" }.join(',')
    report = Snorby::Report.build_report('week')
    attachments["snorby-weekly-report.pdf"] = report[:pdf]
    mail(:to => @emails, :subject => "Snorby Weeklt Report: #{report[:start_time]} - #{report[:end_time]}")
  end
  
  def monthly_report
    @emails = User.all.collect { |user| "#{user.name} <#{user.email}>" }.join(',')
    report = Snorby::Report.build_report('month')
    attachments["snorby-monthly-report.pdf"] = report[:pdf]
    mail(:to => @emails, :subject => "Snorby Monthly Report: #{report[:start_time]} - #{report[:end_time]}")
  end

end
