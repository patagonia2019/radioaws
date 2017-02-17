class RemoveCountryIdFromStations < ActiveRecord::Migration[5.0]
  def change
    remove_column :stations, :country_id, :integer
  end
end
