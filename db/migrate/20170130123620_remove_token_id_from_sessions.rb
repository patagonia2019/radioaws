class RemoveTokenIdFromSessions < ActiveRecord::Migration[5.0]
  def change
    remove_column :sessions, :token_id, :integer
  end
end
