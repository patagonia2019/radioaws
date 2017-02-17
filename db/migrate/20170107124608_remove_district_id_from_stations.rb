class RemoveDistrictIdFromStations < ActiveRecord::Migration[5.0]
  def change
    remove_column :stations, :district_id, :integer
  end
end
