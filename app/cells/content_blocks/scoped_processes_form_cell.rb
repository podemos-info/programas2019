# frozen_string_literal: true

module ContentBlocks
  class ScopedProcessesFormCell < Decidim::ParticipatoryProcesses::ContentBlocks::HighlightedProcessesSettingsFormCell
    def show_unscoped_label
      I18n.t("content_blocks.scoped_processes.show_unscoped")
    end
  end
end
