class Activity < ApplicationRecord
  belongs_to :trackable, polymorphic: true
  belongs_to :user, optional: true

  validates :action, presence: true

  scope :recent, -> { order(created_at: :desc) }
  scope :for_card, ->(card) { where(trackable: card) }
end
