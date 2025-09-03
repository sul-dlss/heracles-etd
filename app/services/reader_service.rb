# frozen_string_literal: true

# Service for assigning readers and performing related actions
class ReaderService
  # @return [Boolean] Assigns or updates readers for a submission
  def self.assign_readers(submission:, readers:)
    new(submission:, readers:).assign_readers
  end

  def self.action(submission:, reader_action_attributes:)
    new(submission:, readers: []).action(submission:, reader_action_attributes:)
  end

  # Records a new reader action for the submission
  def action(submission:, reader_action_attributes:)
    @previous_action = submission.last_reader_action_at
    @new_action = reader_action_attributes[:last_reader_action_at]

    return unless submission.submitted?
    return unless new_action && valid_action?

    submission.update!(reader_action_attributes)

    return unless /rejected/i.match?(submission.readerapproval)

    submission.submitted_at = nil
    submission.submitted_to_registrar = 'false'
  end

  def initialize(submission:, readers:)
    @submission = submission
    @readers = readers
  end

  # Assigns or updates readers for a submission
  def assign_readers
    submission.readers.destroy_all
    submission.readers.create!(readers)
  end

  private

  attr_reader :submission, :readers, :previous_action, :new_action

  def valid_action?
    return false if previous_action && (previous_action - new_action).abs < 1.0

    new_action > submission.submitted_at
  end
end
