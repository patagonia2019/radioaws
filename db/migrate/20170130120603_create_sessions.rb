class CreateSessions < ActiveRecord::Migration[5.0]
  def change
    create_table :sessions do |t|
      t.string :api_key
      t.string :session_id
      t.integer :token_id

      t.timestamps
    end
  end
end
