# frozen_string_literal: true

# Model for legacy dissertation files, which can be associated with submissions
# This model is used for migration and will be removed once all legacy files are migrated
class LegacyDissertationFile < UploadedFile
  def augmented_file_name
    file_name.sub(/\.pdf\z/, '-augmented.pdf')
  end

  def augmented_path
    File.join(Settings.file_uploads_root, druid, augmented_file_name)
  end
end
