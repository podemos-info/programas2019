# frozen_string_literal: true

require "cell/partial"

module ContentBlocks
  class ScopedProcessesCell < Decidim::ParticipatoryProcesses::ContentBlocks::HighlightedProcessesCell
    delegate :user_scope, to: :controller

    def processes
      @processes ||= processes_query
    end

    private

    def processes_query
      @processes_query ||= begin
        ret = Decidim::ParticipatoryProcesses::OrganizationPublishedParticipatoryProcesses.new(current_organization, current_user) |
              Decidim::ParticipatoryProcesses::FilteredParticipatoryProcesses.new("active")
        ret |= scoped_query
        ret = ret.query.limit(max_results)

        if user_scope
          scoped_query.sort_by_scope(ret)
        else
          ret
        end
      end
    end

    def show_unscoped
      model.settings.show_unscoped
    end

    def scoped_query
      @scoped_query ||= ScopedParticipatoryProcesses.new(user_scope, show_unscoped: show_unscoped)
    end
  end
end
