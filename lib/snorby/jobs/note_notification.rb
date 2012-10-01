module Snorby
  module Jobs
    
    class NoteNotification < Struct.new(:note_id)
     
     def perform
      @note = Note.get(note_id)
      NoteMailer.new_note(@note).deliver unless @note.blank?
     end
      
    end
    
  end
end
