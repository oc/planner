class Product < ApplicationRecord
  enum :status, { active: 0, archived: 1 }

  has_many :memberships, dependent: :destroy
  has_many :members, through: :memberships, source: :user
  has_many :cards, dependent: :destroy
  has_many :objectives, dependent: :destroy

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true, format: { with: /\A[a-z0-9-]+\z/, message: "only allows lowercase letters, numbers, and hyphens" }

  before_validation :generate_slug, on: :create

  scope :visible_to, ->(user) { joins(:memberships).where(memberships: { user_id: user.id }) }

  def to_param
    slug
  end

  private

  def generate_slug
    return if slug.present?
    self.slug = name&.parameterize
  end
end
