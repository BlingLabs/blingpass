class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :username
      t.string :password
      t.text :holds
      t.text :flights
      t.integer :count
      t.decimal :threshold
      t.string :password_digest

      t.timestamps
    end
  end
end
