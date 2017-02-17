class CreateStations < ActiveRecord::Migration[5.0]
  def change
    create_table :stations do |t|
      t.string :name
      t.string :tuning_dial
      t.string :hash
      t.boolean :is_am
      t.string :imageUrl
      t.integer :land_id
      t.integer :country_id
      t.integer :district_id
      t.integer :city_id

      t.timestamps
    end
  end
end
