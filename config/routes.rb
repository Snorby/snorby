Snorby::Application.routes.draw do

  devise_for :users, :path_names => { :sign_in => 'login', :sign_out => 'logout', :sign_up => 'register' } do
    get "/login" => "devise/sessions#new"
    get '/logout', :to => "devise/sessions#destroy"
    get '/reset/password', :to => "devise/passwords#edit"
  end

  root :to => "page#dashboard"

  resources :sensors do
  end

  
  resources :admin do
    collection do
      post :severity# => '/severity/:id'
      get :settings
    end
  end

  match ':controller(/:action(/:sid/:cid))', :controller => 'Events'

  resources :events do
    #get "/events/show/:sid/:cid", :to => "events#show", :constraints => { :sid => /\d/, :cid => /\d/ }
    
    collection do
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
