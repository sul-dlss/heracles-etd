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
  end
end
