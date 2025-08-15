# frozen_string_literal: true

FactoryBot.define do
  factory :reader do
    sequence(:sunetid) { |n| "reader#{n}" }
    name { 'Doe, Jim' }
    sequence(:position) { |n| n }
    readerrole { 'Reader' }
    submission

    trait :advisor do
      readerrole { 'Advisor' }
    end
  end
end
