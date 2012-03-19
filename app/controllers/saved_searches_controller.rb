class SavedSearchesController < ApplicationController
  
  def index
    @searches = (SavedSearch.all(:user_id => @current_user.id) | SavedSearch.all(:public => true)).page(params[:page].to_i, :per_page => @current_user.per_page_count, :order => [:created_at])
  end
  
  def new
    @search = SavedSearch.new
    render :layout => false
  end
  
  def create
    if params.has_key?(:search)

      if params[:search].is_a?(String)
        params[:search] = JSON.parse(params[:search])
      end

      params[:search][:user_id] = @current_user.id
      @search = SavedSearch.new(params[:search])
      if @search.save
        render :json => @search
      else
        render :json => { :error => @search.errors }
      end
    end
  end
  
  def show
    @search = SavedSearch.get(params[:id].to_i)

    if @search 
      if @current_user.id == @search.user.id or @search.public
        render :json => @search
      else
        render :json => {}
      end
    else
      render :json => {}
    end
  end

  def view
    @search = SavedSearch.get(params[:id].to_i)

    if @search 
      redirect_to saved_searches_path unless @current_user.id == @search.user.id
    else
      redirect_to saved_searches_path
    end
  end
  
  def edit
    @search = SavedSearch.get(params[:id])
  end
  
  def update
    @search = SavedSearch.get(params[:id])

    if @search && @current_user.id == @search.user.id
      if params.has_key?(:search)

        if params[:search].is_a?(String)
          params[:search] = JSON.parse(params[:search])
        end

        @search.search = params[:search]
      end

      if params.has_key?(:public)
        @search.public = params[:public]
      end

      if @search.save
        render :json => @search
      else
        render :json => { :error => @search.errors }
      end
    else
      render :json => {}
    end
  end

  def title
    @search = SavedSearch.get(params[:id])

    if @search && @current_user.id == @search.user.id
      @search.title = params[:title] if params.has_key?(:title)

      if params.has_key?(:search)

        if params[:search].is_a?(String)
          params[:search] = JSON.parse(params[:search])
        end

        @search.search = params[:search]
      end

      if @search.save
        render :text => @search.title
      else
        render :json => @search.errors
      end
    end

  end

  def destroy
    @search = SavedSearch.get(params[:id])

    respond_to do |format|
      if @search && @current_user.id == @search.user.id
        if @search.destroy
          format.html { redirect_to saved_searches_path, :flash => { :success => "Search `#{@search.title}` removed successfully." } }
        else
          format.html { redirect_to saved_searches_path, :flash => { :error => "Failed to remove search `#{@search.title}` successfully" } }
        end
      else
        format.html { redirect_to saved_searches_path }
      end
    end
  end

end

