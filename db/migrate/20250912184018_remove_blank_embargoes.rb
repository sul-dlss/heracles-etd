class RemoveBlankEmbargoes < ActiveRecord::Migration[8.0]
  def change
    Submission.where(embargo: '').update_all(embargo: nil)
  end
end
