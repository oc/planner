class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :email,           null: false, index: { unique: true }
      t.string :password_digest, null: false
      t.boolean :verified,       null: false, default: false

      t.string :name,            null: false
      t.string :github_username
      t.string :phone
      t.string :avatar_url
      t.integer :role,           null: false, default: 0

      t.timestamps
    end

    add_index :users, :github_username, unique: true, where: "github_username IS NOT NULL"
  end
end
