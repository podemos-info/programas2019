# frozen_string_literal: true

# server-based syntax
# ======================
# Defines a single server with a list of roles and multiple properties.
# You can define all roles on a single server, or split them:

server ENV["STAGING_SERVER_HOST"], port: ENV["STAGING_SERVER_PORT"], user: ENV["STAGING_USER"], roles: %w(app db web)

set :rails_env, :production
set :user, ENV["STAGING_USER"]

# Use RVM system installation
set :rvm_type, :system
set :rvm_custom_path, "/usr/share/rvm"
set :branch, ENV["BRANCH"] || "master"

after "deploy:publishing", "systemd:puma:restart"
after "deploy:publishing", "systemd:sidekiq:restart"
