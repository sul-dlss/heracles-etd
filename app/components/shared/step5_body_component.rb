# frozen_string_literal: true

module Shared
  # Component for rendering the body of step 4 (dissertation file).
  class Step5BodyComponent < ApplicationComponent
    # param [Submission] the submission being edited
    # param [ActionView::Helpers::FormBuilder, nil] form (not included for the show page)
    def initialize(submission:, form: nil)
      @submission = submission
      @form = form
      super()
    end

    attr_reader :submission, :form

    delegate :supplemental_files, to: :submission

    def upload_file_link
      tag.button upload_link_label,
                 class: 'btn btn-link icon-link bi bi-upload',
                 onClick: "document.getElementById('submission_supplemental_files').click();"
    end

    private

    def upload_link_label
      return 'Upload supplemental file' unless supplemental_files.attached?

      'Upload more supplemental files'
    end
  end
end
