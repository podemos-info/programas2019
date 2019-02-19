# frozen_string_literal: true

Decidim.configure do |config|
  config.application_name = "Programas 2019"
  config.mailer_sender = Rails.application.secrets[:mail_from]

  # Change these lines to set your preferred locales
  config.default_locale = :es
  config.available_locales = [:es, :ca, :eu, :gl]

  # Geocoder configuration
  config.geocoder = {
    static_map_url: "https://image.maps.cit.api.here.com/mia/1.6/mapview",
    here_app_id: Rails.application.secrets.geocoder[:here_app_id],
    here_app_code: Rails.application.secrets.geocoder[:here_app_code]
  }

  # Custom resource reference generator method
  # config.reference_generator = lambda do |resource, component|
  #   # Implement your custom method to generate resources references
  #   "1234-#{resource.id}"
  # end

  # Currency unit
  # config.currency_unit = "€"

  # The number of reports which an object can receive before hiding it
  # config.max_reports_before_hiding = 3

  # Custom HTML Header snippets
  #
  # The most common use is to integrate third-party services that require some
  # extra JavaScript or CSS. Also, you can use it to add extra meta tags to the
  # HTML. Note that this will only be rendered in public pages, not in the admin
  # section.
  #
  # Before enabling this you should ensure that any tracking that might be done
  # is in accordance with the rules and regulations that apply to your
  # environment and usage scenarios. This component also comes with the risk
  # that an organization's administrator injects malicious scripts to spy on or
  # take over user accounts.
  #
  config.enable_html_header_snippets = false
end

Rails.application.config.i18n.available_locales = Decidim.available_locales
Rails.application.config.i18n.default_locale = Decidim.default_locale

Decidim::Verifications.register_workflow(:participa_authorization_handler) do |workflow|
  workflow.form = "ParticipaAuthorizationHandler"
end

Decidim.content_blocks.register(:homepage, :scoped_processes) do |content_block|
  content_block.cell = "content_blocks/scoped_processes"
  content_block.public_name_key = "content_blocks.scoped_processes.name"

  content_block.settings_form_cell = "content_blocks/scoped_processes_form"

  content_block.settings do |settings|
    settings.attribute :show_unscoped, type: :boolean
    settings.attribute :max_results, type: :integer, default: 4
  end
end

Decidim::ParticipatoryProcesses::Permissions.class_eval do
  def cannot_view_private_space
    return unless process.private_space

    !(user && (user.admin || process.users.none? || process.users.include?(user)))
  end
end

Decidim::ParticipatoryProcess.class_eval do
  scope :visible_for, lambda { |user|
    if user
      joins("LEFT JOIN decidim_participatory_space_private_users ON decidim_participatory_space_private_users.privatable_to_id = #{table_name}.id")
        .where("(private_space = ? and (decidim_participatory_space_private_users.decidim_user_id IS NULL or decidim_participatory_space_private_users.decidim_user_id = ?))
                or private_space = ? ", true, user, false)
        .distinct
    else
      where(private_space: false)
    end
  }

  def can_participate?(user)
    return true unless private_space?
    return true if user && (users.none? || users.include?(user))

    false
  end
end

Decidim::ParticipatorySpaceContext.module_eval do
  def current_user_can_visit_space?
    current_user&.admin ||
      (current_participatory_space.try(:private_space?) &&
       (current_participatory_space.users.none? ||
        current_participatory_space.users.include?(current_user))) ||
      !current_participatory_space.try(:private_space?) ||
      (current_participatory_space.try(:private_space?) &&
       current_participatory_space.try(:is_transparent?))
  end
end
