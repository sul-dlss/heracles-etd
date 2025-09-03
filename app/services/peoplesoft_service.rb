# frozen_string_literal: true

# Service for applying registrar based actions from Peoplesoft
class PeoplesoftService
  def initialize(submission:)
    @submission = submission
  end

  # Assigns readers and records a new reader action for the submission
  def new_reader_action(readers:, reader_action_attributes:)
    assign_readers(readers)
    @previous_action = submission.last_reader_action_at
    @new_action = reader_action_attributes[:last_reader_action_at]

    return unless valid_action?

    submission.update!(reader_action_attributes)

    return unless /rejected/i.match?(submission.readerapproval)

    submission.update!(rejection_attributes)
  end

  # Records a new registrar action for the submission
  def new_registrar_action(registrar_action_attributes:)
    @previous_action = submission.last_registrar_action_at
    @new_action = registrar_action_attributes[:last_registrar_action_at]

    return unless valid_action?

    submission.update!(registrar_action_attributes)

    return complete_approval unless /reject with modification/i.match?(submission.regapproval)

    submission.update!(rejection_attributes)
  end

  private

  attr_reader :submission, :previous_action, :new_action

  # Assigns or updates readers for a submission
  def assign_readers(readers)
    submission.readers.destroy_all
    submission.readers.create!(readers)
  end

  def complete_approval
    CreateStubMarcRecordJob.perform_later(submission.druid)
    CreateEmbargo.call(submission.druid, submission.embargo_release_date)
  end

  def rejection_attributes
    { submitted_at: nil, submitted_to_registrar: 'false' }
  end

  def valid_action?
    return false unless submission.submitted?
    return false unless new_action
    return false if previous_action && (previous_action - new_action).abs < 1.0

    new_action > submission.submitted_at
  end
end
