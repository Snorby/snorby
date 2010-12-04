class NoteMailer < ActionMailer::Base
  
  def new_note(note)
    @note = note
    @event = @note.event
    @emails = User.all.collect { |user| "#{user.name} <#{user.email}>" if user.accepts_note_notifications?(@event) }.join(',')

    mail(:to => @emails, :from => (Setting.email? ? Setting.find(:email) : "snorby@snorby.org"), :subject => "[Snorby] New Event Note Added")
  end
  
end