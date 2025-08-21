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
    schoolname { 'School of Engineering' }
    department { 'Electrical Engineering' }
    major { 'Computer Science' }
    degreeconfyr { '2023' }
    provost { 'Sam E. Provost' }

    trait :with_orcid do
      orcid { '0000-0002-1825-0097' }
    end

    trait :with_dissertation_file do
      dissertation_file { Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/files/dissertation.pdf'), 'application/pdf') }
    end

    trait :with_augmented_dissertation_file do
      augmented_dissertation_file { Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/files/augmented_dissertation.pdf'), 'application/pdf') }
    end

    trait :with_supplemental_files do
      supplemental_files do
        [
          Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/files/supplemental_1.pdf'), 'application/pdf'),
          Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/files/supplemental_2.pdf'), 'application/pdf')
        ]
      end
    end

    trait :with_permission_files do
      permission_files do
        [
          Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/files/permission_1.pdf'), 'application/pdf'),
          Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/files/permission_2.pdf'), 'application/pdf')
        ]
      end
    end

    trait :submittable do
      with_dissertation_file
      with_supplemental_files
      citation_verified { 'true' }
      abstract { 'Sample abstract' }
      format_reviewed { 'true' }
      sulicense { 'true' }
      cclicense { '3' }
      embargo { '6 months' }
      abstract_provided { 'true' }
      rights_selected { 'true' }
      dissertation_uploaded { 'true' }
    end

    trait :submitted do
      submittable
      submitted_at { DateTime.parse('2023-01-01T00:00:00Z') }
    end

    trait :with_readers do
      transient do
        readers_count { 1 }
      end

      readers { create_list(:reader, readers_count) }
    end

    trait :with_advisors do
      transient do
        advisors_count { 1 }
      end

      readers { create_list(:reader, advisors_count, :advisor) }
    end

    trait :reader_approved do
      readerapproval { 'Approved' }
      last_reader_action_at { DateTime.parse('2020-03-05T14:38:59Z') }
    end
  end
end
