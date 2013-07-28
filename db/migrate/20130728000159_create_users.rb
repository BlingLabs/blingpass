class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :username
      t.text :holds
      t.text :flights

      t.timestamps
    end
  end
end
