# frozen_string_literal: true

# Pin npm packages by running ./bin/importmap

pin 'application'
pin '@hotwired/turbo-rails', to: 'turbo.min.js'
pin '@hotwired/stimulus', to: 'stimulus.min.js'
pin '@hotwired/stimulus-loading', to: 'stimulus-loading.js'
pin_all_from 'app/javascript/controllers', under: 'controllers'
pin 'bootstrap', to: 'bootstrap.bundle.min.js'
pin 'local-time' # @3.0.3

# Entrypoint for ActiveAdmin
pin 'active_admin', preload: true

# ActiveAdmin and dependencies
pin '@activeadmin/activeadmin', to: 'https://cdn.jsdelivr.net/npm/@activeadmin/activeadmin@3.3.0/app/assets/javascripts/active_admin/base.min.js'
pin 'jquery', to: 'https://cdn.jsdelivr.net/npm/jquery@3.7.1/dist/jquery.js'
pin 'jquery-ui', to: 'https://cdn.jsdelivr.net/npm/jquery-ui@1.14.1/dist/jquery-ui.min.js'
pin 'jquery-ujs', to: 'https://cdn.jsdelivr.net/npm/jquery-ujs@1.2.3/src/rails.min.js'
