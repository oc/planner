class CreateObjectives < ActiveRecord::Migration[8.0]
  def change
    create_table :objectives do |t|
      t.references :product, null: true, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.string :period, null: false
      t.integer :status, default: 0, null: false

      t.timestamps
    end

    add_index :objectives, :period
    add_index :objectives, :status
  end
end
