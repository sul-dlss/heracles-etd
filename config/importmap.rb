# frozen_string_literal: true

# Pin npm packages by running ./bin/importmap

pin 'application'
pin '@hotwired/turbo-rails', to: 'turbo.min.js'
pin '@hotwired/stimulus', to: 'stimulus.min.js'
pin '@hotwired/stimulus-loading', to: 'stimulus-loading.js'
pin_all_from 'app/javascript/controllers', under: 'controllers'
pin 'bootstrap', to: 'bootstrap.bundle.min.js'
pin 'local-time' # @3.0.3

# ActiveAdmin
pin '@activeadmin/activeadmin', to: 'https://cdn.jsdelivr.net/npm/@activeadmin/activeadmin@4.0.0-beta16/dist/active_admin.min.js'
