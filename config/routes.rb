# frozen_string_literal: true

Rails.application.routes.draw do
  # Only expose motor-admin in development until an approach to administration is selected
  mount Motor::Admin => '/motor_admin' if Rails.env.development?

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  get '/webauth/login', to: 'authentication#login', as: 'login'
  get '/webauth/logout', to: 'authentication#logout', as: 'logout'
  get '/test_login/:id', to: 'authentication#test_login', as: 'test_login', param: :id if Rails.env.test?

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"

  resources :submissions, only: %i[edit update show]
end
