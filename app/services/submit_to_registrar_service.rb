# frozen_string_literal: true

# Service for submitting a Submission to the registrar after it has been completed by the student.
class SubmitToRegistrarService
  def self.call(...)
    new(...).call
  end

  def initialize(submission:)
    @submission = submission
  end

  def call
    submission.update!(
      submitted_at: Time.zone.now,
      readerapproval: nil,
      last_reader_action_at: nil,
      readercomment: nil,
      regapproval: nil,
      last_registrar_action_at: nil,
      regcomment: nil
    )

    begin
      submission.augmented_dissertation_file.attach(
        io: File.open(augmented_pdf_path),
        filename: File.basename(augmented_pdf_path)
      )
    rescue SignaturePageService::Error => e
      Honeybadger.notify(e, context: { dissertation_id: submission.dissertation_id })
    end

    PsRegistrarService.call(submission:)
  end

  private

  attr_reader :submission

  def augmented_pdf_path
    @augmented_pdf_path ||= SignaturePageService.call(submission: submission)
  end
end
