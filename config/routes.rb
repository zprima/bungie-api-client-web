Rails.application.routes.draw do

  
  # Sessions
  get 'login', to: 'sessions#new', as: :login
  delete 'logout', to: 'sessions#destroy', as: :logout
  get 'auth/destiny/callback', to: 'sessions#create'

  resources :characters, only: [:index]
  resources :progressions, only: [:index]
  resources :inventories, only: [:index]

  get 'data/refresh', to: 'home#refresh', as: :refresh

  # root
  root 'home#index'
end
