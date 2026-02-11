class KeyResult < ApplicationRecord
  belongs_to :objective
  has_many :card_key_results, dependent: :destroy
  has_many :cards, through: :card_key_results

  enum :status, { on_track: 0, at_risk: 1, behind: 2, achieved: 3 }

  validates :title, presence: true

  delegate :product, to: :objective

  def progress_percentage
    return 0 if target_value.nil? || target_value.zero?
    [(current_value.to_f / target_value * 100).round, 100].min
  end

  def update_status!
    pct = progress_percentage
    new_status = if pct >= 100
      :achieved
    elsif pct >= 70
      :on_track
    elsif pct >= 40
      :at_risk
    else
      :behind
    end
    update!(status: new_status)
  end
end
