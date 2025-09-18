class DropFromSubmission < ActiveRecord::Migration[8.0]
  def change
    remove_column :submissions, :cc_license_selected, :string
    remove_column :submissions, :containscopyright, :string
  end
end
