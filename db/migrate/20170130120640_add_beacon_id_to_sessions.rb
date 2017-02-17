class AddBeaconIdToSessions < ActiveRecord::Migration[5.0]
  def change
    add_column :sessions, :beacon_id, :string
  end
end
