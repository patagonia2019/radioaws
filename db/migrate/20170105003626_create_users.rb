class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.string :password_digest
      t.string :remember_digest
      t.boolean :admin
      t.string :address
      t.string :catastro
      t.string :phone
      t.string :mobile

      t.timestamps
    end
  end
end
