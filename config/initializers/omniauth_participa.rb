# frozen_string_literal: true

if Rails.application.secrets.dig(:omniauth, :participa, :enabled)
  require "omniauth/strategies/participa"

  Devise.setup do |config|
    config.omniauth :participa,
                    name: "participa",
                    identifier: Rails.application.secrets.dig(:omniauth, :participa, :openid_identifier)
  end

  Decidim::User.omniauth_providers << :participa
end
