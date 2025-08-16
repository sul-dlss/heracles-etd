# frozen_string_literal: true

# Decorator for Files attached to a submission that provides methods to help display file information.
class FilePresenter
  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::TranslationHelper

  def initialize(file:, required_file_type: nil)
    @file = file
    @required_file_type = required_file_type
  end

  attr_reader :file, :required_file_type

  delegate :filename, :byte_size, :created_at, to: :file

  def values
    [
      filename,
      filetype_display,
      file_size,
      uploaded_at
    ]
  end

  private

  def filetype_display
    return required_file_type if required_file_type

    file.content_type if file.present?
  end

  def file_size
    number_to_human_size(file.byte_size)
  end

  def uploaded_at
    l(created_at)
  end
end
