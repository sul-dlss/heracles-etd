class AddSupplementalFilesProvidedToSubmissions < ActiveRecord::Migration[8.0]
  def change
    add_column :submissions, :supplemental_files_provided, :string
  end
end
