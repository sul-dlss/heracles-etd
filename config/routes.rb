# frozen_string_literal: true

Rails.application.routes.draw do
  ActiveAdmin.routes(self)
  # Only expose motor-admin in development until an approach to administration is selected
  mount Motor::Admin => '/motor_admin' if Rails.env.development?

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"

  # Since external applications reference legacy endpoints, we will continue to support them rather than
  # use Rails routing conventions.

  get 'view/:id' => 'submissions#reader_review', as: :reader_review_submission

  resources :submissions, only: %i[edit update show], path: 'submit' do
    member do
      get :review # Edit review
      post :submit
      get :preview # Signature page preview
    end
  end
end
