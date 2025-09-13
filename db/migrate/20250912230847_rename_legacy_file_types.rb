class RenameLegacyFileTypes < ActiveRecord::Migration[8.0]
  def change
    UploadedFile.where(type: 'PermissionFile').update_all(type: 'LegacyPermissionFile')
    UploadedFile.where(type: 'SupplementalFile').update_all(type: 'LegacySupplementalFile')
    UploadedFile.where(type: 'DissertationFile').update_all(type: 'LegacyDissertationFile')
  end
end
