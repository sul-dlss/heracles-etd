# frozen_string_literal: true

# Generates a draft version of the signature page PDF
class SignaturePagePreviewService
  def self.call(...)
    new(...).call
  end

  def initialize(submission:)
    @submission = submission
  end

  def call
    FileUtils.mkdir_p(preview_dir)
    tempfile = Tempfile.create(['', '.pdf'], preview_dir)
    FileUtils.cp(Rails.root.join('config/preview/base.pdf'), tempfile.path)

    augmented_path = SignaturePageService.call(submission:, dissertation_path: tempfile.path)
    FileUtils.mv(augmented_path, tempfile.path)
    tempfile.path
  end

  private

  attr_reader :submission

  def preview_dir
    Settings.preview_dir
  end
end
