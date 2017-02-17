class AddListenIsWorkingToStreams < ActiveRecord::Migration[5.0]
  def change
    add_column :streams, :listen_is_working, :boolean
  end
end
