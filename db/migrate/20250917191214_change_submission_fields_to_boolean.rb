class ChangeSubmissionFieldsToBoolean < ActiveRecord::Migration[8.0]
  def up
    add_column :submissions, :citation_verified_bool, :boolean, default: false, null: false
    Submission.reset_column_information
    Submission.where(citation_verified: 'true').update_all(citation_verified_bool: true)
    remove_column :submissions, :citation_verified
    rename_column :submissions, :citation_verified_bool, :citation_verified
  end

  def down
    add_column :submissions, :citation_verified_str, :string, default: nil
    Submission.reset_column_information
    Submission.where(citation_verified: true).update_all(citation_verified_str: 'true')
    remove_column :submissions, :citation_verified
    rename_column :submissions, :citation_verified_str, :citation_verified
  end
end
