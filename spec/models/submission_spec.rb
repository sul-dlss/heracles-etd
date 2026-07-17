# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Submission do
  subject(:submission) { build(:submission, druid:) }

  let(:druid) { 'druid:jx000nx0003' }

  describe 'abstract validation' do
    context 'when the abstract step is incomplete' do
      subject(:submission) { build(:submission, abstract: nil, abstract_provided: false) }

      it { is_expected.to be_valid }
    end

    context 'when the abstract step is marked complete with a blank abstract' do
      subject(:submission) { build(:submission, abstract: ' ', abstract_provided: true) }

      it 'is invalid' do
        expect(submission).not_to be_valid
        expect(submission.errors[:abstract]).to include("can't be blank")
      end
    end

    context 'when the abstract step is marked complete with an abstract that is too long' do
      subject(:submission) do
        build(:submission, abstract: 'A' * (described_class::MAX_ABSTRACT_LENGTH + 1), abstract_provided: true)
      end

      it 'is invalid' do
        expect(submission).not_to be_valid
        expect(submission.errors[:abstract]).to include('is too long (maximum is 5000 characters)')
      end
    end

    it 'requires an abstract in the submission validation context regardless of the completion flag' do
      submission = build(:submission, abstract: nil, abstract_provided: false)

      expect(submission).not_to be_valid(:submission)
      expect(submission.errors[:abstract]).to include("can't be blank")
    end

    it 'allows an unrelated update to a legacy record with an inconsistent abstract state' do
      submission = create(:submission)
      submission.update_columns(abstract: nil, abstract_provided: true) # rubocop:disable Rails/SkipsModelValidations

      expect(submission.update(title: 'An updated title')).to be true
      expect(submission.reload.title).to eq('An updated title')
    end
  end

  describe '#abstract_complete?' do
    it 'returns true when a valid abstract is marked complete' do
      submission = build(:submission, abstract: 'My abstract', abstract_provided: true)

      expect(submission.abstract_complete?).to be true
    end

    it 'returns false when a blank abstract is marked complete' do
      submission = build(:submission, abstract: nil, abstract_provided: true)

      expect(submission.abstract_complete?).to be false
    end
  end

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
    context 'when created date is nil' do
      it 'returns nil' do
        expect(submission.doi).to be_nil
      end
    end

    context 'when created date is before the date the DOI service was enabled' do
      subject(:submission) do
        Timecop.freeze(Date.parse('2025-09-17')) do
          create(:submission, druid:)
        end
      end

      it 'returns nil' do
        expect(submission.doi).to be_nil
      end
    end

    context 'when created date is after or the same as the date the DOI service was enabled' do
      subject(:submission) { create(:submission, druid:) }

      it 'returns the DOI for the submission' do
        expect(submission.doi).to eq('10.80343/jx000nx0003')
      end
    end
  end

  describe '#purl' do
    it 'returns the PURL for the submission' do
      expect(submission.purl).to eq('https://sul-purl-stage.stanford.edu/jx000nx0003')
    end
  end

  describe '#accessioning_started?' do
    context 'when accessioning_started_at property is present' do
      subject(:submission) { build(:submission, :accessioning_started, druid:) }

      it 'returns true' do
        expect(submission.accessioning_started?).to be true
      end
    end

    context 'when accessioning_started_at property is blank' do
      subject(:submission) { build(:submission, druid:) }

      it 'returns false' do
        expect(submission.accessioning_started?).to be false
      end
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

    let(:augmented_dissertation_path) { Tempfile.create.path }
    let(:now) { Time.zone.now }

    before do
      allow(Time.zone).to receive(:now).and_return(now)
      FileUtils.cp(file_fixture('dissertation-augmented.pdf'), augmented_dissertation_path)
      allow(SignaturePageService).to receive(:call).and_return(augmented_dissertation_path)
    end

    after do
      FileUtils.rm_f(augmented_dissertation_path)
    end

    it 'sets the submitted_at property' do
      expect { submission.prepare_to_submit! }.to change(submission, :submitted_at).from(nil).to(now)
    end

    context 'when the abstract is blank' do
      before do
        submission.save!
        # Simulate a legacy inconsistent record that predates the validation.
        submission.update_columns(abstract: nil, abstract_provided: true) # rubocop:disable Rails/SkipsModelValidations
      end

      it 'does not mark the submission as submitted' do
        expect { submission.prepare_to_submit! }.to raise_error(ActiveRecord::RecordInvalid)
        expect(submission.reload.submitted_at).to be_nil
      end
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
      expect(File.exist?(augmented_dissertation_path)).to be false
      expect(submission.augmented_dissertation_file.filename.to_s).to eq('dissertation-augmented.pdf')
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
        expect(submission.submitted_to_registrar).to eq('false')
        expect(submission.cclicensetype).to be_nil
      end
    end

    context 'when primary fields are set' do
      subject(:submission) do
        create(:submission, abstract: 'My abstract', sulicense: true, cclicense: '1', submitted_at: Time.zone.now)
      end

      it 'sets derivative fields' do
        expect(submission.submitted_to_registrar).to eq('true')
        expect(submission.cclicensetype).to eq('CC Attribution license')
      end
    end
  end
end
