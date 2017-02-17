class AddInternalHashFromStations < ActiveRecord::Migration[5.0]
  def change
    add_column :stations, :internal_hash, :string
  end
end
