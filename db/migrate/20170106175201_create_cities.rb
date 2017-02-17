class CreateCities < ActiveRecord::Migration[5.0]
  def change
    create_table :cities do |t|
      t.string :name
      t.integer :district_id

      t.timestamps
    end
  end
end
