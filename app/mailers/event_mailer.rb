class EventMailer < ActionMailer::Base
  
  def event_information(event, emails, subject, note, user)
    @event = event
    @user = user
    @emails = emails.split(',')
    @note = note

    @from = (Setting.email? ? Setting.find(:email) : "snorby@snorby.org")
    
    mail(:to => @emails, :from => @from, :subject => "[Snorby Event] #{subject}")
  end
  
end
