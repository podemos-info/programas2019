# frozen_string_literal: true

load Decidim::ParticipatoryProcesses::Engine.root.join("app/controllers/decidim/participatory_processes/admin/participatory_processes_controller.rb")

module Decidim
  module ParticipatoryProcesses
    module Admin
      ParticipatoryProcessesController.class_eval do
        private

        # Fix participatory processes order
        def collection
          @collection ||= Decidim::ParticipatoryProcessesWithUserRole.for(current_user).order(slug: :asc)
        end
      end
    end
  end
end
