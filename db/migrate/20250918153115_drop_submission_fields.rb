class DropSubmissionFields < ActiveRecord::Migration[8.0]
  def change
    remove_column :submissions, :ps_plan, :string
    remove_column :submissions, :ps_program, :string
    remove_column :submissions, :advisor, :string
    remove_column :submissions, :term, :string
    remove_column :submissions, :submit_date, :date
    remove_column :submissions, :catkey, :string
  end
end
