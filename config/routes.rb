# frozen_string_literal: true

Rails.application.routes.draw do
  root 'transactions#index'

  post 'authenticate', to: 'authentication#authenticate'
  resources :merchants
  resources :transactions, only: [:index, :create]
end
