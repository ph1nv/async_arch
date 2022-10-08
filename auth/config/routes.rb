Rails.application.routes.draw do
  use_doorkeeper
  devise_for :accounts
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  root 'accounts#index'
  resources :accounts, only: [:index, :edit, :update, :destroy]
  get '/accounts/current', to: 'accounts#current'
end
