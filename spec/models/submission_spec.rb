# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Submission do
  subject(:submission) { build(:submission, druid: 'druid:jx000nx0003') }

  describe '#first_name' do
    it 'returns the first name from the name field' do
      expect(submission.first_name).to eq('Jane')
    end
  end

  describe '#first_last_name' do
    it 'returns the first name followed by the last name from the name field' do
      expect(submission.first_last_name).to eq('Jane Doe')
    end

    context 'when suffix is present' do
      it 'includes the suffix in the full name' do
        submission.suffix = 'Jr.'
        expect(submission.first_last_name).to eq('Jane Doe, Jr.')
      end
    end
  end

  describe '#doi' do
    it 'returns the DOI for the submission' do
      expect(submission.doi).to eq('10.80343/jx000nx0003')
    end
  end

  describe '#purl' do
    it 'returns the PURL for the submission' do
      expect(submission.purl).to eq('https://sul-purl-stage.stanford.edu/jx000nx0003')
    end
  end

  describe '#thesis?' do
    it 'returns true if the submission is a thesis' do
      expect(submission.thesis?).to be true
    end

    it 'returns false if the submission is not a thesis' do
      submission.etd_type = 'dissertation'
      expect(submission.thesis?).to be false
    end
  end

  describe 'derivative fields' do
    context 'when primary fields are not set' do
      subject(:submission) { create(:submission) }

      it 'sets derivative fields' do
        expect(submission.cc_license_selected).to eq('false')
        expect(submission.submitted_to_registrar).to eq('false')
        expect(submission.cclicensetype).to be_nil
      end
    end

    context 'when primary fields are set' do
      subject(:submission) do
        create(:submission, abstract: 'My abstract', sulicense: 'true', cclicense: '1', submitted_at: Time.zone.now)
      end

      it 'sets derivative fields' do
        expect(submission.cc_license_selected).to eq('true')
        expect(submission.submitted_to_registrar).to eq('true')
        expect(submission.cclicensetype).to eq('CC Attribution license')
      end
    end
  end
end
