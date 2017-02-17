class AddUrlTypeToStations < ActiveRecord::Migration[5.0]
  def change
    add_column :stations, :url_type, :string
  end
end
