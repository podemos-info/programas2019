# frozen_string_literal: true

proposals = Decidim.find_component_manifest(:proposals)

update_options = proc do |instance|
  if instance.is_a?(Hash)
    component = instance[:component]
    resource = instance[:resource]
  else
    component = instance
    resource = nil
  end
  scope = component.participatory_space.scope

  options = scope ? { "scope_type_#{scope.scope_type_id}" => scope.id.to_s } : {}

  permissions = Hash[
    proposals.actions.map do |action|
      [action, { "authorization_handler_name" => "participa_authorization_handler", "options" => options }]
    end
  ]

  (resource || component).update!(permissions: permissions)
end

proposals.on(:create, &update_options)
proposals.on(:update, &update_options)
proposals.on(:permission_update, &update_options)
