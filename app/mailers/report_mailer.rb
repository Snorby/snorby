class ReportMailer < ActionMailer::Base
  
  def daily_report
    @emails = []
    User.all.each { |user| @emails << "#{user.name} <#{user.email}>" }
    report = Snorby::Report.build_report('yesterday')
    attachments["snorby-daily-report.pdf"] = report[:pdf]
    mail(:to => @emails, :from => (Setting.email? ? Setting.find(:email) : "snorby@snorby.org"), :subject => "Snorby Daily Report: #{report[:start_time]} - #{report[:end_time]}")
  end

  def weekly_report
    @emails = []
    User.all.each { |user| @emails << "#{user.name} <#{user.email}>" }
    report = Snorby::Report.build_report('week')
    attachments["snorby-weekly-report.pdf"] = report[:pdf]
    mail(:to => @emails, :from => (Setting.email? ? Setting.find(:email) : "snorby@snorby.org"), :subject => "Snorby Weeklt Report: #{report[:start_time]} - #{report[:end_time]}")
  end
  
  def monthly_report
    @emails = []
    User.all.each { |user| @emails << "#{user.name} <#{user.email}>" }
    report = Snorby::Report.build_report('month')
    attachments["snorby-monthly-report.pdf"] = report[:pdf]
    mail(:to => @emails, :from => (Setting.email? ? Setting.find(:email) : "snorby@snorby.org"), :subject => "Snorby Monthly Report: #{report[:start_time]} - #{report[:end_time]}")
  end

end
