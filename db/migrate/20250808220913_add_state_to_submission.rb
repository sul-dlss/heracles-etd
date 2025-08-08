class AddStateToSubmission < ActiveRecord::Migration[8.0]
  def change
    add_column :submissions, :submission_state, :string, default: 'registered', null: false
  end
end
