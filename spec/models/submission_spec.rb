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

  describe '#to_peoplesoft_hash' do
    subject(:submission) { build(:submission, :submitted) }

    it 'returns the submission as a hash of attributes PeopleSoft requires' do
      expect(submission.to_peoplesoft_hash).to eq({
                                                    dissertation_id: submission.dissertation_id,
                                                    purl: submission.purl,
                                                    timestamp: submission.submitted_at,
                                                    title: submission.title,
                                                    type: submission.etd_type
                                                  })
    end
  end

  describe '#prepare_to_submit!' do
    # NOTE: I can't imagine how a submission could be in this state, but it
    #       helps us ensure `#prepare_to_submit!` changes all the values as
    #       expected. On most calls, the fields that are `nil`ed out will
    #       already be `nil`.
    subject(:submission) { build(:submission, :submittable, :reader_approved, :registrar_approved) }

    let(:augmented_dissertation_path) { file_fixture('dissertation-augmented.pdf') }
    let(:now) { Time.zone.now }

    before do
      allow(Time.zone).to receive(:now).and_return(now)
      allow(SignaturePageService).to receive(:call).and_return(augmented_dissertation_path)
    end

    it 'sets the submitted_at property' do
      expect { submission.prepare_to_submit! }.to change(submission, :submitted_at).from(nil).to(now)
    end

    %i[readerapproval last_reader_action_at readercomment regapproval last_registrar_action_at
       regcomment].each do |property|
      it "clears the #{property} property on the submission" do
        expect { submission.prepare_to_submit! }.to change { submission.public_send(property) }.to(nil)
      end
    end

    it 'invokes the SignaturePageService to generate the augmented dissertation file' do
      submission.prepare_to_submit!
      expect(SignaturePageService).to have_received(:call).once.with(submission:)
    end

    it 'attaches the augmented dissertation file to the submission' do
      expect { submission.prepare_to_submit! }.to change { submission.augmented_dissertation_file.attached? }
                                              .from(false).to(true)
    end

    context 'when the SignaturePageService raises an error' do
      before do
        allow(SignaturePageService).to receive(:call).and_raise(RuntimeError, 'PDF could not generate!')
        allow(Honeybadger).to receive(:notify)
      end

      it 'raises the exception' do
        expect { submission.prepare_to_submit! }.to raise_error(RuntimeError)
      end
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
