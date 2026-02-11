class ExternalLink < ApplicationRecord
  enum :provider, { github: 0, gitlab: 1, shortcut: 2, linear: 3 }
  enum :sync_status, { synced: 0, pending: 1, error: 2 }

  belongs_to :card

  validates :external_id, presence: true
  validates :external_url, presence: true
end
