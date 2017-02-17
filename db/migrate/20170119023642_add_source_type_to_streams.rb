class AddSourceTypeToStreams < ActiveRecord::Migration[5.0]
  def change
    add_column :streams, :source_type, :string
  end
end
