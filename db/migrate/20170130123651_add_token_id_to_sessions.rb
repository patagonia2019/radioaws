class AddTokenIdToSessions < ActiveRecord::Migration[5.0]
  def change
    add_column :sessions, :token_id, :string
  end
end
