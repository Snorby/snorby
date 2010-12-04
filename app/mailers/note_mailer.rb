class NoteMailer < ActionMailer::Base
  
  def new_note(note)
    @note = note
    @event = @note.event
    @users = []
    
    User.all.each do |user|
      @users << "#{user.name}, <#{user.email}>" if user.accepts_note_notifications?(@event)
    end

    mail(:to => @users.join(','), 
    :from => Setting.find(:email) || "snorby@snorby.org", 
    :subject => "[Snorby] New Event Note Added")
  end
  
end