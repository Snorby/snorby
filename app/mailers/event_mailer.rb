class EventMailer < ActionMailer::Base
  
  def event_information(event, emails, subject, note, user)
    @event = event
    @user = user
    @emails = emails.split(',')
    @note = note

    @from = (Setting.email? ? Setting.find(:email) : "snorby@example.com")
    
    mail(:to => @emails, :from => @from, :subject => "[Snorby Event] #{subject}")
  end
  
end
