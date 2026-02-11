class CreateScenarios < ActiveRecord::Migration[8.0]
  def change
    create_table :scenarios do |t|
      t.references :card, null: false, foreign_key: true
      t.string :title
      t.text :given
      t.text :when_clause
      t.text :then_clause
      t.integer :status
      t.integer :position

      t.timestamps
    end
  end
end
