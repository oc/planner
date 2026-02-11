class Membership < ApplicationRecord
  enum :role, { owner: 0, member: 1, viewer: 2 }

  belongs_to :user
  belongs_to :product

  validates :user_id, uniqueness: { scope: :product_id }
end
