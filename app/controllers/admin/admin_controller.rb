# frozen_string_literal: true

module Admin
  # Controller for admin actions
  class AdminController < ApplicationController
    def test_submission
      authorize! default: AdminPolicy

      dissertation_id = format('%010d', Kernel.rand(1..9_999_999_999))

      submission = Submission.create!(
        dissertation_id:,
        title: "Test Submission for #{current_user.sunetid} (#{dissertation_id})",
        sunetid: current_user.sunetid,
        degree: 'Ph.D.',
        name: 'Pretender, Student',
        schoolname: 'Humanities & Sciences',
        department: 'Philosophy',
        major: 'Philosophy',
        degreeconfyr: '2029',
        etd_type: 'Thesis',
        druid:
      )

      redirect_to edit_submission_path(submission.dissertation_id)
    end

    private

    def druid
      letters = 'bcdfghjkmnpqrstvwxyz'.chars.freeze

      idx = (Submission.maximum(:id) || 0) + 1
      format_str = 'druid:%s%s%03d%s%s%04d'
      format(format_str, letters.sample, letters.sample,
             idx / 10_000, letters.sample, letters.sample, idx)
    end
  end
end
