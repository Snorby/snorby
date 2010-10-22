Snorby::Application.routes.draw do

  devise_for :users, :path_names => { :sign_in => 'login', :sign_out => 'logout', :sign_up => 'register' } do
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

  match ':controller(/:action(/:sid/:cid))', :controller => 'Events'

  resources :events do
    
    collection do
      get :queue
      post :favorite
      get :last
      get :since
    end
    
  end

  resources :users do
    
  end

  resources :page do

  end

end
