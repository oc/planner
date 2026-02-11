class CreateKeyResults < ActiveRecord::Migration[8.0]
  def change
    create_table :key_results do |t|
      t.references :objective, null: false, foreign_key: true
      t.string :title, null: false
      t.decimal :target_value, precision: 10, scale: 2, default: 0
      t.decimal :current_value, precision: 10, scale: 2, default: 0
      t.string :unit
      t.integer :status, default: 0, null: false

      t.timestamps
    end

    add_index :key_results, :status
  end
end
