# frozen_string_literal: true

# Model for permission files.
class PermissionFile < ApplicationRecord
  belongs_to :submission, inverse_of: :permission_files
  has_one_attached :file, dependent: :purge_later

  delegate :blob, :filename, :content_type, :byte_size, to: :file
end
