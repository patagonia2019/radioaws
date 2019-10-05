class CreateArchivecatalogs < ActiveRecord::Migration[5.0]
  def change
    create_table :archivecatalogs do |t|
      t.string :identifier
      t.string :title
      t.string :subtitle
      t.string :detail

      t.timestamps
    end
  end
end
