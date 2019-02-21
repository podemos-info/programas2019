# frozen_string_literal: true

Decidim::ParticipatoryProcesses::Permissions.class_eval do
  def cannot_view_private_space
    !can_view_private_space?
  end

  def can_view_private_space?
    return true unless process.private_space
    return false unless user

    user.admin || process.users.none? || process.users.include?(user)
  end
end

Decidim::ParticipatorySpaceContext.module_eval do
  def current_user_can_visit_space?
    return true unless current_participatory_space.try(:private_space?) &&
                       !current_participatory_space.try(:is_transparent?)
    return false unless current_user

    current_user.admin || current_participatory_space.users.none? || current_participatory_space.users.include?(current_user)
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
    return false unless user

    users.none? || users.include?(user)
  end
end

Decidim::Meetings::Meeting.class_eval do
  def can_participate?(user)
    can_participate_space?(user) && can_participate_meeting?(user)
  end

  private

  def can_participate_space?(user)
    return true unless participatory_space.try(:private_space?)
    return false unless user

    participatory_space.users.none? || participatory_space.users.include?(user)
  end

  def can_participate_meeting?(user)
    return true unless private_meeting?
    return false unless user

    registrations.exists?(decidim_user_id: user.id)
  end
end
