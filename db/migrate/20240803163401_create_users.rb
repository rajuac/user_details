class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :name 
      t.string :email
      t.integer :age 
      t.string :mobile
      t.string :city
      t.timestamps
    end
    add_index :users, :id, unique: true

  end
end
