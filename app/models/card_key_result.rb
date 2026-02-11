class CardKeyResult < ApplicationRecord
  belongs_to :card
  belongs_to :key_result

  validates :card_id, uniqueness: { scope: :key_result_id }
end
