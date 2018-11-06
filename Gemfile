# frozen_string_literal: true

source "https://rubygems.org"

ruby RUBY_VERSION

gem "dotenv-rails", require: "dotenv/rails-now"

gem "bootsnap", "~> 1.3"
gem "decidim", "0.14.3"
gem "omniauth-openid"
gem "puma", "~> 3.0"
gem "uglifier", "~> 4.1"

group :development, :test do
  gem "byebug", "~> 10.0", platform: :mri
  gem "capistrano", "~> 3.11.0", require: false
  gem "capistrano-rails", "~> 1.3", require: false
  gem "capistrano-rvm", require: false
  gem "capistrano-systemd-multiservice", require: false
  gem "decidim-dev", "0.14.3"
  gem "faker", "~> 1.9"
  gem "pry-rails"
  gem "rubocop", require: false
end

group :development do
  gem "letter_opener_web", "~> 1.3"
  gem "listen", "~> 3.1"
  gem "spring", "~> 2.0"
  gem "spring-watcher-listen", "~> 2.0"
  gem "web-console", "~> 3.5"
end
