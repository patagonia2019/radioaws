class RemoveTypeFromStations < ActiveRecord::Migration[5.0]
  def change
    remove_column :stations, :type, :string
  end
end
