# frozen_string_literal: true

class ParticipaAuthorizationHandler < Decidim::AuthorizationHandler
  BLOCKING_ACTIVITY = %w(proposals proposal_votes).freeze

  attribute :participa_id, Integer
  attribute :vote_town, String

  def metadata
    return current_metadata if current_metadata && has_activity?

    super.merge(participa_id: participa_id, vote_town: vote_town, **scope_types)
  end

  def unique_id
    participa_id
  end

  private

  def scope_types
    @scope_types ||= Hash[
      user.organization.scope_types.map do |scope_type|
        [
          :"scope_#{scope_type.name["en"].parameterize}",
          (scope ? scope.part_of_scopes.select { |scope| scope.scope_type == scope_type } .last&.id : nil) || "-1"
        ]
      end
    ]
  end

  def scope
    user.organization.scopes.find_by(code: vote_town[0..4])
  end

  def current_metadata
    @current_metadata ||= Decidim::Authorization.find_by(user: user, name: "participa_authorization_handler")&.metadata
  end

  def has_activity?
    @has_activity ||= Decidim::Gamification::BadgeScore.where(badge_name: BLOCKING_ACTIVITY, user: user).sum(:value).positive?
  end
end
