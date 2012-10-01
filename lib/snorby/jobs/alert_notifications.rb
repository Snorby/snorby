module Snorby
  module Jobs
    
    class AlertNotifications < Struct.new(:event_sid, :event_cid)
     
     def perform
      @event = Event.get(event_sid, event_cid)
      NotificationMailer.alert(@event).deliver unless @event.blank?
     end
      
    end
    
  end
end
