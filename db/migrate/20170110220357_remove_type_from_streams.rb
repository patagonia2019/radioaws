class RemoveTypeFromStreams < ActiveRecord::Migration[5.0]
  def change
    remove_column :streams, :type, :string
  end
end
