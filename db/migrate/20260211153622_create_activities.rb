class CreateActivities < ActiveRecord::Migration[8.0]
  def change
    create_table :activities do |t|
      t.references :trackable, polymorphic: true, null: false
      t.references :user, null: false, foreign_key: true
      t.string :action
      t.jsonb :change_data

      t.timestamps
    end
  end
end
