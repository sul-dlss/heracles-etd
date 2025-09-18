class DropLegacyAttachments < ActiveRecord::Migration[8.0]
  def change
    drop_table :attachments
    drop_table :uploaded_files
  end
end
