# frozen_string_literal: true

FactoryBot.define do
  factory :uploaded_file do
    factory :legacy_dissertation_file, class: 'LegacyDissertationFile', parent: :uploaded_file do
      file_name { 'dissertation.pdf' }
      type { 'LegacyDissertationFile' }
      label { 'Dissertation File' }
    end

    factory :legacy_supplemental_file, class: 'LegacySupplementalFile', parent: :uploaded_file do
      file_name { 'supplemental_1.pdf' }
      type { 'LegacySupplementalFile' }
      label { 'Supplemental File' }
    end

    factory :legacy_permission_file, class: 'LegacyPermissionFile', parent: :uploaded_file do
      file_name { 'permission_1.pdf' }
      type { 'LegacyPermissionFile' }
      label { 'Permission File' }
    end
  end
end
