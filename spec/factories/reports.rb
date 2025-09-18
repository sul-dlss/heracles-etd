# frozen_string_literal: true

FactoryBot.define do
  factory :report do
    sequence(:label) { |n| "Report - Season Year #{n}" }
    sequence(:description) { |n| "The season of year #{n}" }
    start_date { '2025-03-31 00:00:00.000000000 -0700' }
    end_date { '2025-06-22 23:59:00.000000000 -0700' }
  end
end
