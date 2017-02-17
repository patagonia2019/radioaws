class AddUrlTypeToStreams < ActiveRecord::Migration[5.0]
  def change
    add_column :streams, :url_type, :string
  end
end
