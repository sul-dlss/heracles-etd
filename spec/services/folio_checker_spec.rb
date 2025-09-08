# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FolioChecker do
  let(:folio_instance_hrid) { 'in123' }
  let(:druid) { 'druid:bd185gs2259' }
  let(:submission) { create(:submission, folio_instance_hrid:, druid:) }
  let(:has_folio_instance) { true }

  before do
    allow(FolioClient).to receive(:has_instance_status?)
      .with(
        hrid: folio_instance_hrid,
        status_id: Settings.catalog.folio.status.cataloged_uuid
      )
      .and_return(has_folio_instance)
  end

  describe '.cataloged?' do
    context 'when the record exists and is cataloged' do
      it 'indicates if the record is cataloged' do
        expect(described_class.cataloged?(submission:)).to be true
      end
    end

    context 'when the record exists but does not have a folio hrid yet' do
      let(:folio_instance_hrid) { nil }

      it 'indicates if the record is cataloged' do
        expect(described_class.cataloged?(submission:)).to be false
      end
    end

    context 'when the record exists but is not yet cataloged' do
      let(:has_folio_instance) { false }

      it 'indicates if the record is cataloged' do
        expect(described_class.cataloged?(submission:)).to be false
      end
    end

    context 'when the record does not exist' do
      before do
        allow(Honeybadger).to receive(:notify)
        allow(FolioClient).to receive(:has_instance_status?)
          .with(hrid: folio_instance_hrid, status_id: Settings.catalog.folio.status.cataloged_uuid)
          .and_raise(FolioClient::ResourceNotFound, "No matching instance found for #{folio_instance_hrid}")
      end

      it 'raises an error' do
        expect do
          described_class.cataloged?(submission:)
        end.to raise_error(FolioClient::ResourceNotFound)
      end
    end
  end
end
