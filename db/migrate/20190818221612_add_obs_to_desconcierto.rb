class AddObsToDesconcierto < ActiveRecord::Migration[5.0]
  def change
    add_column :desconciertos, :obs, :string
  end
end
