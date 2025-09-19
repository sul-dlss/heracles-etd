# frozen_string_literal: true

set :application, 'etd'
set :repo_url, 'https://github.com/sul-dlss/heracles-etd.git'

# Default branch is :main
ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, "/opt/app/etd/#{fetch(:application)}"

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :log_level is :debug
set :log_level, :info

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# append :linked_files, 'config/database.yml' # From puppet

# Default value for linked_dirs is []
append :linked_dirs, 'log', 'config/settings', 'config/soap', 'tmp/pids', 'tmp/cache', 'tmp/sockets',
       'public/system', 'public/reports'

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
# set :keep_releases, 5

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure

# honeybadger_env otherwise defaults to rails_env
set :honeybadger_env, fetch(:stage)

# Set Rails env to production in all Cap environments
set :rails_env, 'production'

# update shared_configs before restarting app (from dlss-capistrano gem)
before 'deploy:restart', 'shared_configs:update'

# Manage SolidQueue via systemd (from dlss-capistrano gem)
set :solid_queue_systemd_role, :app
set :solid_queue_systemd_use_hooks, true

# configure capistrano-rails to work with propshaft instead of sprockets
# (we don't have public/assets/.sprockets-manifest* or public/assets/manifest*.*)
set :assets_manifests, -> { [release_path.join('public', fetch(:assets_prefix), '.manifest.json')] }
