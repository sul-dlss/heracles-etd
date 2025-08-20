# frozen_string_literal: true

module Admin
  # Service to create a dummy submission for testing purposes.
  # This is used in the admin interface to generate test data.
  class DummySubmissionService
    def self.call(...)
      new(...).call
    end

    def initialize(sunetid:)
      @sunetid = sunetid
    end

    def call
      dissertation_id = format('%010d', Kernel.rand(1..9_999_999_999))

      submission = Submission.create!(
        dissertation_id:,
        title: "Test Submission for #{sunetid} (#{dissertation_id})",
        sunetid: sunetid,
        degree: 'Ph.D.',
        name: 'Pretender, Student',
        schoolname: 'Humanities & Sciences',
        department: 'Philosophy',
        major: 'Philosophy',
        degreeconfyr: '2029',
        etd_type: 'Thesis',
        druid:
      )
      submission.readers.create!(
        sunetid: sunetid,
        position: 1,
        name: 'Pretender, Advisor',
        readerrole: 'Advisor'
      )
      submission
    end

    private

    attr_reader :sunetid

    def druid
      letters = 'bcdfghjkmnpqrstvwxyz'.chars.freeze

      idx = (Submission.maximum(:id) || 0) + 1
      format_str = 'druid:%s%s%03d%s%s%04d'
      format(format_str, letters.sample, letters.sample,
             idx / 10_000, letters.sample, letters.sample, idx)
    end
  end
end
