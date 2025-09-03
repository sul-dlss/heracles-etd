# frozen_string_literal: true

# Service for assigning registrar related peoplesoft actions
class RegistrarService
  def self.action(submission:, registrar_action_attributes:)
    new(submission:).action(submission:, registrar_action_attributes:)
  end

  # Records a new reader action for the submission
  def action(submission:, registrar_action_attributes:)
    @previous_action = submission.last_registrar_action_at
    @new_action = registrar_action_attributes[:last_registrar_action_at]

    return unless submission.submitted?
    return unless new_action && valid_action?

    submission.update!(registrar_action_attributes)

    case submission.regapproval
    when /reject with modification/i
      submission.submitted_at = nil
      submission.submitted_to_registrar = 'false'
    when /^approved$/i
      CreateStubMarcRecordJob.perform_later(submission.druid)
      # CreateEmbargo.call(submission.druid, submission.embargo_release_date)
    end
  end

  def initialize(submission:)
    @submission = submission
  end

  private

  attr_reader :submission, :previous_action, :new_action

  def valid_action?
    return false if previous_action && (previous_action - new_action).abs < 1.0

    new_action > submission.submitted_at
  end
end
