Snorby::Application.routes.draw do

  devise_for :users, :path_names => { :sign_in => 'login', :sign_out => 'logout', :sign_up => 'register' } do
    get "/login" => "devise/sessions#new"
    get 'logout', :to => "devise/sessions#destroy"
    get 'reset/password', :to => "devise/passwords#edit"
  end

  root :to => "page#dashboard"

  resources :users do
    
  end

  resources :page do

  end

end
