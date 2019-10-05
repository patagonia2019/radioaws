class AddIdentifierToArchiveOrgAudio < ActiveRecord::Migration[5.0]
  def change
    add_column :archive_org_audios, :identifer, :string
  end
end
