# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CatalogStatusJob do
  subject(:job) { described_class.new }

  let(:submission) do
    create(:submission, :submitted, :loaded_in_ils)
  end

  let(:druid) { submission.druid }
  let(:folio_checker) { instance_double(FolioChecker) }

  before do
    allow(FolioChecker).to receive(:new).with(submission:).and_return(folio_checker)
    allow(folio_checker).to receive(:cataloged?).and_return(true)
    allow(StartAccessionJob).to receive(:perform_later)
    allow(Honeybadger).to receive(:check_in)
  end

  describe '#perform' do
    it 'updates the submission and triggers accessioning when cataloged' do
      expect(submission.ils_record_updated_at).to be_nil

      job.perform
      submission.reload
      expect(submission.ils_record_updated_at).not_to be_nil
      expect(StartAccessionJob).to have_received(:perform_later).with(druid)
      expect(Honeybadger).to have_received(:check_in).with(Settings.honeybadger_checkins.catalog_status)
    end

    context 'when not cataloged' do
      before do
        allow(folio_checker).to receive(:cataloged?).and_return(false)
      end

      it 'does not update the submission or trigger accessioning' do
        expect(submission.ils_record_updated_at).to be_nil

        job.perform
        submission.reload
        expect(submission.ils_record_updated_at).to be_nil
        expect(StartAccessionJob).not_to have_received(:perform_later)
        expect(Honeybadger).to have_received(:check_in).with(Settings.honeybadger_checkins.catalog_status)
      end
    end
  end
end
