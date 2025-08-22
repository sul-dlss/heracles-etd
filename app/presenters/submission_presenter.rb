# frozen_string_literal: true

# Presenter that provides methods to help determine when steps are done.
class SubmissionPresenter
  CITATION_STEP = 'citation'
  ABSTRACT_STEP = 'abstract'
  FORMAT_STEP = 'format'
  RIGHTS_STEP = 'rights'
  SUBMITTED_STEP = 'submitted'
  DISSERTATION_STEP = 'dissertation'
  SUPPLEMENTAL_FILES_STEP = 'supplemental_files'
  PERMISSION_FILES_STEP = 'permission_files'

  CITATION_STEP_FIELD = :citation_verified
  ABSTRACT_STEP_FIELD = :abstract_provided
  FORMAT_STEP_FIELD = :format_reviewed
  RIGHTS_STEP_FIELD = :rights_selected
  SUBMITTED_STEP_FIELD = :submitted_to_registrar
  DISSERTATION_UPLOADED_FIELD = :dissertation_uploaded
  SUPPLEMENTAL_FILES_UPLOADED_FIELD = :supplemental_files_uploaded
  PERMISSION_FILES_UPLOADED_FIELD = :permission_files_uploaded

  STEP_TO_FIELD = {
    CITATION_STEP => CITATION_STEP_FIELD, # step 1
    ABSTRACT_STEP => ABSTRACT_STEP_FIELD, # step 2
    FORMAT_STEP => FORMAT_STEP_FIELD, # step 3
    DISSERTATION_STEP => DISSERTATION_UPLOADED_FIELD, # step 4
    SUPPLEMENTAL_FILES_STEP => SUPPLEMENTAL_FILES_UPLOADED_FIELD, # step 5
    PERMISSION_FILES_STEP => PERMISSION_FILES_UPLOADED_FIELD, # step 6
    RIGHTS_STEP => RIGHTS_STEP_FIELD, # step 7
    SUBMITTED_STEP => SUBMITTED_STEP_FIELD # step 8
  }.freeze

  def self.all_done?(submission:)
    # All done excluding step last
    (STEP_TO_FIELD.keys - [SUBMITTED_STEP]).all? { |step| step_done?(step:, submission:) }
  end

  def self.total_steps
    STEP_TO_FIELD.keys.size
  end

  def self.step_done?(step:, submission:)
    submission.public_send(step_field(step:)) == 'true'
  end

  def self.step_number(step:)
    STEP_TO_FIELD.keys.index(step) + 1
  end

  def self.step_field(step:)
    STEP_TO_FIELD.fetch(step)
  end

  def self.done_id(step:)
    "step-#{step_number(step:)}-done"
  end
end
