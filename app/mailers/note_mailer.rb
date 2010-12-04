class NoteMailer < ActionMailer::Base

  def new_note(note)
    @note = note
    @event = @note.event
    @emails = User.all.collect { |user| user.accepts_note_notifications?(@event) ? "#{user.name} <#{user.email}>" : "" }.join(',')

    @from = (Setting.email? ? Setting.find(:email) : "snorby@snorby.org")
    @to = (@emails.blank? ? @from : @emails)

    mail(:to => @to, :from => @from, :subject => "[Snorby] New Event Note Added")
  end

end
