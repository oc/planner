class User < ApplicationRecord
  has_secure_password

  enum :role, {
    engineer: 0,
    sales: 1,
    product_owner: 2,
    project_manager: 3,
    tech_lead: 4,
    design: 5
  }

  generates_token_for :email_verification, expires_in: 2.days do
    email
  end

  generates_token_for :password_reset, expires_in: 20.minutes do
    password_salt.last(10)
  end

  has_many :sessions, dependent: :destroy
  has_many :memberships, dependent: :destroy
  has_many :products, through: :memberships
  has_many :owned_cards, class_name: "Card", foreign_key: :owner_id, dependent: :nullify
  has_many :comments, dependent: :destroy
  has_many :activities, dependent: :nullify

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, allow_nil: true, length: { minimum: 12 }
  validates :name, presence: true

  normalizes :email, with: -> { _1.strip.downcase }
  normalizes :github_username, with: -> { _1&.strip&.gsub(/^@/, "") }

  before_validation if: :email_changed?, on: :update do
    self.verified = false
  end

  after_update if: :password_digest_previously_changed? do
    sessions.where.not(id: Current.session).delete_all
  end

  def gravatar_url(size: 80)
    hash = Digest::MD5.hexdigest(email.downcase)
    "https://www.gravatar.com/avatar/#{hash}?s=#{size}&d=mp"
  end

  def avatar
    avatar_url.presence || gravatar_url
  end
end
