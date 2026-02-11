class CreateProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :products do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.text :description
      t.integer :status, null: false, default: 0
      t.jsonb :settings, null: false, default: {}

      t.timestamps
    end

    add_index :products, :slug, unique: true
    add_index :products, :status
  end
end
