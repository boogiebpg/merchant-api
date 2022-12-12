# frozen_string_literal: true

Rails.application.routes.draw do
  root 'transactions#index'
  resources :merchants
  post 'authenticate', to: 'authentication#authenticate'
  post 'transactions/create'
  get 'transactions', to: 'transactions#index'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
