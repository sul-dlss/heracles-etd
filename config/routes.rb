# frozen_string_literal: true

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

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

  get 'view/:id', to: redirect('/submissions/%{id}/reader_review'), as: :legacy_view_show
  get 'submit/:id', to: redirect('/submissions/%{id}'), as: :legacy_submit_show
  get 'submit/:id/edit', to: redirect('/submissions/%{id}/edit'), as: :legacy_submit_edit

  mount MissionControl::Jobs::Engine, at: '/jobs'
  ActiveAdmin.routes(self)
end
