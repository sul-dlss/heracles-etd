# frozen_string_literal: true

FactoryBot.define do
  factory :submission do
    sequence(:dissertation_id) { |n| format('%08<number>d', number: n) }
    druid { generate(:unique_druid) }
    etd_type { 'Thesis' }
    sequence(:title) { |n| "My Thesis #{n}" }
    sequence(:sunetid) { |n| "user#{n}" }
    name { 'Doe, Jane' }
    degree { 'Ph.D.' }

    trait :with_dissertation_file do
      after(:build) do |submission|
        submission.dissertation_file.attach(
          io: Rails.root.join('spec/fixtures/files/dissertation.pdf').open,
          filename: 'dissertation.pdf',
          content_type: 'application/pdf'
        )
      end
    end

    trait :with_supplemental_files do
      after(:build) do |submission|
        submission.supplemental_files.attach(
          io: Rails.root.join('spec/fixtures/files/supplemental_1.pdf').open,
          filename: 'supplemental_1.pdf',
          content_type: 'application/pdf'
        )

        submission.supplemental_files.attach(
          io: Rails.root.join('spec/fixtures/files/supplemental_2.pdf').open,
          filename: 'supplemental_2.pdf',
          content_type: 'application/pdf'
        )
      end
    end

    trait :with_permission_file do
      after(:build) do |submission|
        submission.permission_files.attach(
          io: Rails.root.join('spec/fixtures/files/permission.pdf').open,
          filename: 'permission.pdf',
          content_type: 'application/pdf'
        )
      end
    end
  end
end
