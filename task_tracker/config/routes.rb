Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  root 'auth#temp_page'
  get 'auth/:provider/callback', to: 'auth#create'
  get '/signin', to: 'auth#index'

  resources :tasks, only: [:index, :new, :create]
  get '/tasks/my', to: 'tasks#my'
  get '/tasks/shuffle', to: 'tasks#shuffle'
end
