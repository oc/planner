class CreateCards < ActiveRecord::Migration[8.0]
  def change
    create_table :cards do |t|
      t.references :product, null: false, foreign_key: true
      t.references :owner, null: false, foreign_key: { to_table: :users }
      t.string :title, null: false
      t.text :description
      t.integer :card_type, null: false, default: 0
      t.integer :stage, null: false, default: 0
      t.integer :priority, null: false, default: 2
      t.integer :position
      t.jsonb :metadata, null: false, default: {}
      t.jsonb :gate_checklist, null: false, default: {}
      t.references :parent, foreign_key: { to_table: :cards }

      t.timestamps
    end

    add_index :cards, [:product_id, :stage, :position]
    add_index :cards, [:product_id, :card_type]
  end
end
