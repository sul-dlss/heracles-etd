# frozen_string_literal: true

FactoryBot.define do
  factory :supplemental_file do
    submission

    # Yes, this supplemental filename has a composed diacritic, so we test that they work.
    trait :first_supplement do
      description { 'Supplemental file supplémental_1.pdf' }
      file { Rack::Test::UploadedFile.new(file_fixture('supplémental_1.pdf'), 'application/pdf') }
    end

    trait :second_supplement do
      description { 'Supplemental file supplemental_2.pdf' }
      file { Rack::Test::UploadedFile.new(file_fixture('supplemental_2.pdf'), 'application/pdf') }
    end
  end
end
