# frozen_string_literal: true

Decidim::DecidimDeviseMailer.class_eval do
  helper_method :accept_invitation_url

  def accept_invitation_url(_resource, host:, **_params)
    new_user_session_url(host: host)
  end
end
