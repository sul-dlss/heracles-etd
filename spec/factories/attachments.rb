# frozen_string_literal: true

FactoryBot.define do
  factory :attachment do
    submission

    trait :with_legacy_dissertation_file do
      uploaded_file { association :legacy_dissertation_file }
    end

    trait :with_legacy_supplemental_file do
      uploaded_file { association :legacy_supplemental_file }
    end

    trait :with_legacy_permission_file do
      uploaded_file { association :legacy_permission_file }
    end
  end
end
