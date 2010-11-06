class PageController < ApplicationController

  def dashboard
    @events = Event.all(:limit => 20)
    a = @events.all(Event.signature.sig_priority.like => 1).size
    b = @events.all(Event.signature.sig_priority.like => 2).size
    c = @events.all(Event.signature.sig_priority.like => 3).size
  end

end
