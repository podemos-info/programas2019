# frozen_string_literal: true

require "sidekiq/web"

Rails.application.routes.draw do
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?
  mount Decidim::Core::Engine => "/"

  mount Sidekiq::Web => "/queues"
end
