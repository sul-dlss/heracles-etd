# frozen_string_literal: true

module Elements
  # Component for displaying a table with attached files
  class AttachedFilesComponent < ApplicationComponent
    def initialize(file_type:, label: nil, files: [], required_file_type: nil, upload_button: nil)
      @file_type = file_type
      @label = label
      @files = files
      @required_file_type = required_file_type
      @upload_button = upload_button
      super()
    end

    attr_reader :file_type, :label, :files, :required_file_type, :upload_button

    def headers
      [
        { label: "#{label} (maximum size 1GB)" },
        { label: 'Type' },
        { label: 'Size' },
        { label: 'Upload Date' }
      ]
    end

    def id
      "#{file_type}-file-table"
    end

    def data
      { step4_target: "#{file_type}FileTable" }
    end

    def values_for_file(file)
      [
        filename_display(file),
        filetype_display(file),
        file_size(file),
        uploaded_at(file)
      ]
    end

    private

    def filename_display(file)
      return upload_file_link if file.blank?

      file.filename
    end

    def filetype_display(file)
      return required_file_type if required_file_type

      file.content_type if file.present?
    end

    def file_size(file)
      return if file.blank?

      number_to_human_size(file.byte_size)
    end

    def uploaded_at(file)
      return if file.blank?

      l(file.created_at)
    end

    def upload_link_label
      return "Upload #{required_file_type}" if required_file_type
      return "Upload #{file_type} file" if files.compact.empty?

      "Upload more #{file_type} files"
    end

    def upload_file_link
      tag.button upload_link_label,
                 class: 'btn btn-link icon-link bi bi-upload',
                 onClick: "document.getElementById('#{upload_button}').click();"
    end
  end
end
