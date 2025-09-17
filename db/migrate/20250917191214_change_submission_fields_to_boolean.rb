class ChangeSubmissionFieldsToBoolean < ActiveRecord::Migration[8.0]
  FIELDS = %i[citation_verified abstract_provided dissertation_uploaded].freeze
  def up
    # add_column :submissions, :citation_verified_bool, :boolean, default: false, null: false
    # Submission.reset_column_information
    # Submission.where(citation_verified: 'true').update_all(citation_verified_bool: true)
    # remove_column :submissions, :citation_verified
    # rename_column :submissions, :citation_verified_bool, :citation_verified
    FIELDS.each { |field| column_str_to_bool(field) }
  end

  def down
    # add_column :submissions, :citation_verified_str, :string, default: nil
    # Submission.reset_column_information
    # Submission.where(citation_verified: true).update_all(citation_verified_str: 'true')
    # remove_column :submissions, :citation_verified
    # rename_column :submissions, :citation_verified_str, :citation_verified
    FIELDS.each { |field| column_bool_to_str(field) }
  end

  def column_str_to_bool(column)
    temp_column = :"#{column}_bool"
    add_column :submissions, temp_column, :boolean, default: false, null: false
    Submission.reset_column_information
    Submission.where(**[[column, 'true']].to_h).update_all(**[[temp_column, true]].to_h)
    remove_column :submissions, column
    rename_column :submissions, temp_column, column
  end

  def column_bool_to_str(column)
    temp_column = :"#{column}_str"
    add_column :submissions, temp_column, :string, default: nil
    Submission.reset_column_information
    Submission.where(**[[column, true]].to_h).update_all(**[[temp_column, 'true']].to_h)
    remove_column :submissions, column
    rename_column :submissions, temp_column, column
  end

  # abstract_provided
end
