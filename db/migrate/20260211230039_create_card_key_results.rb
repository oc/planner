class CreateCardKeyResults < ActiveRecord::Migration[8.0]
  def change
    create_table :card_key_results do |t|
      t.references :card, null: false, foreign_key: true
      t.references :key_result, null: false, foreign_key: true
      t.text :expected_impact
      t.text :actual_impact

      t.timestamps
    end

    add_index :card_key_results, [:card_id, :key_result_id], unique: true
  end
end
