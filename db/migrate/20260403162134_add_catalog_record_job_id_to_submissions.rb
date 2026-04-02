class AddCatalogRecordJobIdToSubmissions < ActiveRecord::Migration[8.0]
  def change
    add_column :submissions, :catalog_record_job_id, :string
  end
end
