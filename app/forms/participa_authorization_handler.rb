# frozen_string_literal: true

class ParticipaAuthorizationHandler < Decidim::AuthorizationHandler
  include ParticipaContext

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

  alias current_user user

  def scope_types
    @scope_types ||= Hash[
      current_user.organization.scope_types.map do |scope_type|
        [
          :"scope_#{scope_type.name["en"].parameterize}",
          (user_scope ? user_scope.part_of_scopes.select { |scope| scope.scope_type == scope_type } .last&.id.to_s : nil) || "-1"
        ]
      end
    ]
  end

  def current_metadata
    @current_metadata ||= authorization&.metadata
  end

  def has_activity?
    @has_activity ||= Decidim::Gamification::BadgeScore.where(badge_name: BLOCKING_ACTIVITY, user: user).sum(:value).positive?
  end
end
