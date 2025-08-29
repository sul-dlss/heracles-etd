# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PostSubmissionJob do
  subject(:job) { described_class.new }

  let(:submission) do
    create(:submission, :submitted, :with_dissertation_file, :with_augmented_dissertation_file,
           :with_supplemental_files, :with_permission_files)
  end

  before do
    allow(SubmissionPoster).to receive(:call)
  end

  describe '#perform' do
    it 'invokes the submission poster service' do
      job.perform(submission:)

      expect(SubmissionPoster).to have_received(:call).once
    end
  end
end
