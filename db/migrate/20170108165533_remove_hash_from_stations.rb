class RemoveHashFromStations < ActiveRecord::Migration[5.0]
  def change
    remove_column :stations, :hash, :string
  end
end
