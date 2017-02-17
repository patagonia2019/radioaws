class RemoveUrlTypeFromStations < ActiveRecord::Migration[5.0]
  def change
    remove_column :stations, :url_type, :string
  end
end
