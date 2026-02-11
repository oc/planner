module Trackable
  extend ActiveSupport::Concern

  included do
    has_many :activities, as: :trackable, dependent: :destroy

    after_create :track_creation
    after_update :track_update
  end

  private

  def track_creation
    return unless Current.user

    activities.create!(
      user: Current.user,
      action: "created",
      change_data: { title: try(:title) || try(:name) }
    )
  end

  def track_update
    return unless Current.user
    return if saved_changes.keys == ["updated_at"]
    return if saved_changes.keys.include?("position") && saved_changes.keys.size <= 2

    tracked_changes = saved_changes.except("updated_at", "position", "gate_checklist")

    return if tracked_changes.empty?

    activities.create!(
      user: Current.user,
      action: "updated",
      change_data: tracked_changes.transform_values { |v| { from: v[0], to: v[1] } }
    )
  end
end
