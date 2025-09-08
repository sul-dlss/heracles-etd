class AddPermissionFilesTable < ActiveRecord::Migration[8.0]
  def change
    create_table :permission_files do |t|
      t.text :description
      t.references :submission, null: false, foreign_key: true
      t.timestamps
    end
  end
end
