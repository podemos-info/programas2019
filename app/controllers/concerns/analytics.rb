# frozen_string_literal: true

require "active_support/concern"

# This concern add methods and helpers to simplify analytics configuration.
module Analytics
  extend ActiveSupport::Concern

  included do
    helper_method :analytics?, :matomo_server, :matomo_site_id
  end

  private

  def analytics?
    @analytics ||= matomo_server.present?
  end

  def matomo_server
    @matomo_server ||= Rails.application.secrets.analytics[:matomo_server]
  end

  def matomo_site_id
    @matomo_site_id ||= Rails.application.secrets.analytics[:matomo_site_id]
  end
end
