class NoteMailer < ActionMailer::Base
  
  def new_note(note)
    @note = note
    @event = @note.event
    @emails = User.all.collect { |user| user.accepts_note_notifications?(@event) ? "#{user.name} <#{user.email}>" : "" }.join(',')

    mail(:to => @emails, :from => (Setting.email? ? Setting.find(:email) : "snorby@snorby.org"), :subject => "[Snorby] New Event Note Added")
  end
  
end