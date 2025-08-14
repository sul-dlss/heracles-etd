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

    trait :with_orcid do
      orcid { '0000-0002-1825-0097' }
    end

    trait :submittable do
      citation_verified { 'true' }
      abstract { 'Sample abstract' }
      format_reviewed { 'true' }
      sulicense { 'true' }
      cclicense { '3' }
      embargo { '6 months' }
    end

    trait :submitted do
      submittable
      submitted_at { DateTime.parse('2023-01-01T00:00:00Z') }
    end
  end
end
