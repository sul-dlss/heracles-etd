# frozen_string_literal: true

module Edit
  # Component for editing the dissertation upload step of the submitter form
  class DissertationStepComponent < ApplicationComponent
    def initialize(submission:)
      @submission = submission
      super()
    end

    attr_reader :submission

    delegate :dissertation_file, to: :submission

    def done_disabled?
      !dissertation_file.attached?
    end

    def dissertation_file_data
      {
        controller: 'submit',
        # After a file is added, set the focus to the done button.
        action: 'click->focus#saveFocus submit#submit',
        focus_id_param: SubmissionPresenter.done_id(step: SubmissionPresenter::DISSERTATION_STEP)
      }
    end
  end
end
