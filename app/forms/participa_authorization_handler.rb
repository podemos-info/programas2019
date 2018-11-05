# frozen_string_literal: true

class ParticipaAuthorizationHandler < Decidim::AuthorizationHandler
  attribute :participa_id, Integer
  attribute :vote_town, String

  def metadata
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
          :"scope_#{scope_type.name["es"].parameterize}",
          (scope ? scope.part_of_scopes.select { |scope| scope.scope_type == scope_type } .last&.id : nil) || "-1"
        ]
      end
    ]
  end

  def scope
    user.organization.scopes.find_by(code: vote_town)
  end
end
