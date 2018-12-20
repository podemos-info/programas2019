# frozen_string_literal: true

# server-based syntax
# ======================
# Defines a single server with a list of roles and multiple properties.
# You can define all roles on a single server, or split them:

server ENV["PRODUCTION_SERVER_HOST"], port: ENV["PRODUCTION_SERVER_PORT"], user: ENV["PRODUCTION_USER"], roles: %w(app db web)

set :rails_env, :production
set :user, ENV["PRODUCTION_USER"]

# Use RVM system installation
set :rvm_type, :system
set :rvm_custom_path, "/usr/share/rvm"

after "deploy:publishing", "systemd:puma:restart"
after "deploy:publishing", "systemd:sidekiq:restart"
