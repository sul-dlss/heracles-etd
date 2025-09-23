class DropExternalVisibilityFromSubmission < ActiveRecord::Migration[8.0]
  def change
    remove_column :submissions, :external_visibility, :string
  end
end
