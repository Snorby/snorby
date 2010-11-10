class NotesController < ApplicationController
  
  before_filter :find_event
  
  def find_event
    @event = Event.get(params[:sid], params[:cid])
    @user = User.current_user
  end
  
  def index
  end
  
  def new
  end
  
  def create
    @note = @event.notes.create({
      :user => @user,
      :body => params[:body]
    })
    if @note.save
    else
    end
  end
  
  def show
  end
  
  def edit
  end
  
  def update
  end
  
  def destroy
  end

end
