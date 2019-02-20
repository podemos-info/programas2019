# frozen_string_literal: true

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
