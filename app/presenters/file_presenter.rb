# frozen_string_literal: true

# Decorator for Files attached to a submission that provides methods to help display file information.
class FilePresenter
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::TranslationHelper

  def initialize(file: nil, required_file_type: nil, label: nil, button: nil)
    @file = file
    @required_file_type = required_file_type
    @label = label
    @button = button
  end

  attr_reader :file, :label, :button, :required_file_type

  delegate :filename, :byte_size, :created_at, to: :file

  def values
    [
      filename_display,
      required_file_type,
      number_to_human_size(file_size),
      uploaded_at
    ]
  end

  private

  def file_size
    return if file.blank?

    number_to_human_size(byte_size)
  end

  def filename_display
    return upload_file_link if file.blank?

    filename
  end

  def upload_file_link
    tag.button label,
               class: 'btn btn-link icon-link bi bi-upload',
               onClick: "document.getElementById('#{button}').click();"
  end

  def uploaded_at
    return if file.blank?

    l(created_at)
  end
end
