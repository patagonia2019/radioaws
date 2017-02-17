class CreateLands < ActiveRecord::Migration[5.0]
  def change
    create_table :lands do |t|
      t.string :name

      t.timestamps
    end
  end
end
