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
  end
end
