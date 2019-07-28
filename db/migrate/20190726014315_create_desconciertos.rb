class CreateDesconciertos < ActiveRecord::Migration[5.0]
  def change
    create_table :desconciertos do |t|
      t.date :at_date
      t.string :url1
      t.string :url2
      t.string :url3

      t.timestamps
    end
  end
end
