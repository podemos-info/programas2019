# frozen_string_literal: true

# Expose current organization to all cells
Decidim::ViewModel.class_eval do
  delegate :current_organization, to: :controller
end
