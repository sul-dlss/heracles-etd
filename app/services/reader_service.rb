# frozen_string_literal: true

# Service for assigning readers and performing related actions
class ReaderService
  # @return [Boolean] Assigns or updates readers for a submission
  def self.assign_readers(submission:, readers:)
    new(submission:, readers:).assign_readers
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

  attr_reader :submission, :readers
end
