class Objective < ApplicationRecord
  belongs_to :product, optional: true
  has_many :key_results, dependent: :destroy

  enum :status, { active: 0, achieved: 1, missed: 2, abandoned: 3 }

  validates :title, presence: true
  validates :period, presence: true

  scope :company_level, -> { where(product: nil) }
  scope :for_product, ->(product) { where(product: product) }
  scope :for_period, ->(period) { where(period: period) }
  scope :active, -> { where(status: :active) }

  def company_level?
    product_id.nil?
  end

  def progress_percentage
    return 0 if key_results.empty?
    key_results.sum(&:progress_percentage) / key_results.count
  end
end
