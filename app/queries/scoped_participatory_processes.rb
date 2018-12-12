# frozen_string_literal: true

# This query class filters participatory processes given a scope.
class ScopedParticipatoryProcesses < Rectify::Query
  def initialize(scope, show_unscoped: false)
    @scope = scope
    @show_unscoped = show_unscoped
  end

  def query
    Decidim::ParticipatoryProcess.where(decidim_scope_id: searched_scopes)
  end

  def sort_by_scope(relation)
    relation.sort do |pp1, pp2|
      searched_scopes.index(pp1.decidim_scope_id) <=> searched_scopes.index(pp2.decidim_scope_id)
    end
  end

  private

  def searched_scopes
    @searched_scopes ||= Array(@scope&.part_of_scopes&.map(&:id)).tap { |scopes| scopes.prepend(nil) if @show_unscoped }
  end
end
