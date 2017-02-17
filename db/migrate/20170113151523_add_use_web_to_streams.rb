class AddUseWebToStreams < ActiveRecord::Migration[5.0]
  def change
    add_column :streams, :use_web, :boolean
  end
end
