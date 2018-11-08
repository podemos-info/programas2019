# frozen_string_literal: true

require "cell/partial"

module ContentBlocks
  class ScopedHighlightedProcessesCell < Decidim::ParticipatoryProcesses::ContentBlocks::HighlightedProcessesCell
    delegate :user_scope, to: :controller

    def highlighted_processes
      @highlighted_processes ||= processes_query.query
    end

    private

    def processes_query
      @processes_query ||= begin
        ret = Decidim::ParticipatoryProcesses::OrganizationPublishedParticipatoryProcesses.new(current_organization, current_user) |
              Decidim::ParticipatoryProcesses::HighlightedParticipatoryProcesses.new |
              Decidim::ParticipatoryProcesses::FilteredParticipatoryProcesses.new("active")
        ret |= ScopedParticipatoryProcesses.new(user_scope) if user_scope
        ret
      end
    end
  end
end
