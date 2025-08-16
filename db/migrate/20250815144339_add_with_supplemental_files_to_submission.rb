class AddWithSupplementalFilesToSubmission < ActiveRecord::Migration[8.0]
  def change
    add_column :submissions, :with_supplemental_files, :boolean, default: false, null: false
  end
end
