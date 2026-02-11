class Scenario < ApplicationRecord
  enum :status, { draft: 0, approved: 1, verified: 2, failed: 3 }

  belongs_to :card

  validates :title, presence: true

  acts_as_list scope: :card_id

  scope :ordered, -> { order(position: :asc) }
end
