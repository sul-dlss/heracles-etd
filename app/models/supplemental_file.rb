# frozen_string_literal: true

# Model for supplemental files.
class SupplementalFile < ApplicationRecord
  belongs_to :submission, inverse_of: :supplemental_files
  has_one_attached :file, dependent: :purge_later

  delegate :blob, :filename, :content_type, :byte_size, to: :file
end
