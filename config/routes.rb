# frozen_string_literal: true

Rails.application.routes.draw do
  ActiveAdmin.routes(self)

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"

  resources :submissions, only: %i[edit update show] do
    member do
      get :review # Edit review
      post :submit
      get :reader_review
      get :preview # Signature page preview
      patch :attach_supplemental_files
    end
  end

  resources :supplemental_files, only: %i[update]
  resources :etds, only: %i[index create]

  mount MissionControl::Jobs::Engine, at: '/jobs'
end
