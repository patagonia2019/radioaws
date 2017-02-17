class AddHeadIsWorkingToStreams < ActiveRecord::Migration[5.0]
  def change
    add_column :streams, :head_is_working, :boolean
  end
end
