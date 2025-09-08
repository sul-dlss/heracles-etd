# frozen_string_literal: true

FactoryBot.define do
  factory :permission_file do
    submission

    # Yes, this permission filename has a composed diacritic, so we test that they work.
    trait :first_permission do
      description { 'Permission file permission_1.pdf' }
      file { Rack::Test::UploadedFile.new(file_fixture('permission_1.pdf'), 'application/pdf') }
    end

    trait :second_permission do
      description { 'Permission file permission_2.pdf' }
      file { Rack::Test::UploadedFile.new(file_fixture('permission_2.pdf'), 'application/pdf') }
    end
  end
end
