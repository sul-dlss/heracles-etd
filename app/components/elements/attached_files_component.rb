# frozen_string_literal: true

module Elements
  # Component for displaying a table with attached files
  class AttachedFilesComponent < ApplicationComponent
    def initialize(file_type:, files:, label:, required_file_type: nil, upload_button: nil)
      @file_type = file_type
      @label = label
      @files = files
      @required_file_type = required_file_type
      @upload_button = upload_button
      super()
    end

    attr_reader :file_type, :label, :files, :required_file_type, :upload_button

    def id
      "#{file_type}-file-table"
    end

    def data
      { step4_target: "#{file_type}FileTable" }
    end

    def upload_file_link
      tag.button upload_link_label,
                 class: 'btn btn-link icon-link bi bi-upload',
                 onClick: "document.getElementById('#{upload_button}').click();"
    end

    private

    def upload_link_label
      return "Upload #{required_file_type}" if required_file_type
      return "Upload #{file_type} file" if files.compact.empty?

      "Upload more #{file_type} files"
    end
  end
end
