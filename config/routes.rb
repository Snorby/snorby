Snorby::Application.routes.draw do

  resources :jobs do
    member do
      get :last_error
      get :handler
    end
  end

  resources :classifications

  devise_for :users, :path_names => { :sign_in => 'login', :sign_out => 'logout', :sign_up => 'register' }, :controllers => {:registrations => "registrations"} do
    get "/login" => "devise/sessions#new"
    get '/logout', :to => "devise/sessions#destroy"
    get '/reset/password', :to => "devise/passwords#edit"
  end

  root :to => "page#dashboard"

  resources :sensors do
  end

  resources :settings do
    
  end
  
  resources :severities do
    
  end


  match '/dashboard', :controller => 'Page', :action => 'dashboard'
  
  match ':controller(/:action(/:sid/:cid))', :controller => 'Events'

  resources :events do
    
    resources :notes do
      
    end
    
    collection do
      post :export
      get :lookup
      get :history
      post :classify
      post :mass_update
      get :queue
      post :favorite
      get :last
      get :since
    end
    
  end
  
  resources :notes

  resources :users do
    collection do
      post :remove
      post :add
    end
  end

  resources :page do

  end

end
