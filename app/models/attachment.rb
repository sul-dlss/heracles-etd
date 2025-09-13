# frozen_string_literal: true

# Model for attachments that link uploaded files to submissions
class Attachment < ApplicationRecord
  belongs_to :submission
  belongs_to :uploaded_file
end
