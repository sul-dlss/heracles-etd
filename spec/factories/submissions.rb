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
      dissertation_file { Rack::Test::UploadedFile.new(file_fixture('dissertation.pdf'), 'application/pdf') }
    end

    trait :with_augmented_dissertation_file do
      with_dissertation_file
      augmented_dissertation_file { Rack::Test::UploadedFile.new(file_fixture('dissertation-augmented.pdf'), 'application/pdf') }
    end

    trait :with_supplemental_files do
      supplemental_files do
        [
          create(:supplemental_file, :first_supplement),
          create(:supplemental_file, :second_supplement)
        ]
      end
    end

    trait :with_permission_files do
      permission_files do
        [
          create(:permission_file, :first_permission),
          create(:permission_file, :second_permission)
        ]
      end
    end

    trait :submittable do
      with_dissertation_file
      with_supplemental_files
      with_permission_files
      citation_verified { true }
      abstract { 'Sample abstract' }
      format_reviewed { true }
      sulicense { true }
      cclicense { '3' }
      embargo { '6 months' }
      abstract_provided { true }
      rights_selected { true }
      dissertation_uploaded { true }
      permissions_provided { 'true' }
    end

    trait :submitted do
      submittable
      with_augmented_dissertation_file
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
      last_reader_action_at { DateTime.parse('2020-03-05T14:38:59Z') }
      readerapproval { 'Approved' }
      readercomment { 'Well written!' }
      with_readers
    end

    trait :registrar_approved do
      last_registrar_action_at { DateTime.parse('2020-03-06T12:38:00Z') }
      regapproval { 'Approved' }
      regcomment { 'Congratulations.' }
    end

    trait :ready_for_cataloging do
      reader_approved
      registrar_approved
    end

    trait :loaded_in_ils do
      sequence(:folio_instance_hrid) { |n| format('a%05<number>d', number: n) }
    end

    trait :cataloged_in_ils do
      ils_record_updated_at { DateTime.parse('2020-03-10T15:00:00Z') }
    end
  end
end
