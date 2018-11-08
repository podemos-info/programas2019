# frozen_string_literal: true

# This query class filters participatory processes given a scope.
class ScopedParticipatoryProcesses < Rectify::Query
  def initialize(scope)
    @scope = scope
  end

  def query
    Decidim::ParticipatoryProcess.where(scope: @scope.part_of_scopes)
  end
end
