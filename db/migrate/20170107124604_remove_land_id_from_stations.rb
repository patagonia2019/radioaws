class RemoveLandIdFromStations < ActiveRecord::Migration[5.0]
  def change
    remove_column :stations, :land_id, :integer
  end
end
