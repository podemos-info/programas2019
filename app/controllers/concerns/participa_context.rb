# frozen_string_literal: true

require "active_support/concern"

# This concern add methods and helpers to simplify access to Participa context.
module ParticipaContext
  extend ActiveSupport::Concern

  def user_scope
    return nil unless current_user

    current_user.organization.scopes.find_by(code: vote_town[0..4])
  end

  def vote_town
    @vote_town ||= authorization&.metadata&.fetch("vote_town")
  end

  def authorization
    @authorization ||= Decidim::Authorization.find_by(user: current_user, name: "participa_authorization_handler")
  end
end
