# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SubmissionPresenter do
  describe '.all_done?' do
    subject(:all_done) { described_class.all_done?(submission:) }

    let(:submission) { build(:submission, :submittable) }

    it { is_expected.to be true }

    context 'when the abstract is blank despite being marked complete' do
      before do
        submission.abstract = nil
        submission.abstract_provided = true
      end

      it { is_expected.to be false }
    end
  end
end
