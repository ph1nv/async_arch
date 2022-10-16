Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  root 'auth#temp_page'
  get 'auth/:provider/callback', to: 'auth#create'
  get '/signin', to: 'auth#index'
end
