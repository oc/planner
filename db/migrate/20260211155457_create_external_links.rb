class CreateExternalLinks < ActiveRecord::Migration[8.0]
  def change
    create_table :external_links do |t|
      t.references :card, null: false, foreign_key: true
      t.integer :provider
      t.string :external_id
      t.string :external_url
      t.integer :sync_status
      t.datetime :last_synced_at
      t.jsonb :metadata

      t.timestamps
    end
  end
end
