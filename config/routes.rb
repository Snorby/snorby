Snorby::Application.routes.draw do

  root :to => "page#dashboard"

  resources :page do

  end

end
