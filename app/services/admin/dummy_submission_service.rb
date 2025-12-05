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
      new_submission.tap do |submission|
        submission.druid = RegisterService.register(submission:).externalIdentifier
        submission.readers.build(
          sunetid: sunetid,
          position: 1,
          name: 'Pretender, Advisor',
          readerrole: 'Advisor'
        )
        submission.save!
      end
    end

    private

    attr_reader :sunetid

    def new_submission
      Submission.new(
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
        embargo: 'immediately'
      )
    end

    def dissertation_id
      format('%010d', Kernel.rand(1..9_999_999_999))
    end
  end
end
