# frozen_string_literal: true

require 'rails_helper'
require 'dry-monads'

RSpec.describe Marc::CatalogIdentifierImporter do
  include Dry::Monads[:result]

  subject(:importer) { described_class.new(submission:) }

  let(:submission) { create(:submission, catalog_record_job_id: 'some_job_id') }

  # rubocop:disable RSpec/SubjectStub
  describe '.import' do
    before do
      allow(described_class).to receive(:new).and_return(importer)
      allow(importer).to receive(:import)
    end

    it 'calls #import on a new instance' do
      described_class.import(submission:)
      expect(importer).to have_received(:import).once
    end
  end
  # rubocop:enable RSpec/SubjectStub

  describe '#import' do
    let(:instance_hrids) { Success(['in12345']) }
    let(:job_status) do
      instance_double(FolioClient::JobStatus,
                      job_execution_id: submission.catalog_record_job_id,
                      wait_until_complete: Success(),
                      instance_hrids:)
    end

    before do
      allow(FolioClient::JobStatus).to receive(:new).and_return(job_status)
      allow(Honeybadger).to receive(:context)
    end

    it 'adds the job_execution_id to Honeybadger context' do
      importer.import
      expect(Honeybadger).to have_received(:context).with(job_execution_id: submission.catalog_record_job_id).once
    end

    it 'returns the instance HRID supplied by the job status' do
      expect(importer.import).to eq('in12345')
    end

    context 'when instance HRID retrieval fails' do
      let(:instance_hrids) { Failure('Something went wrong') }

      it 'raises an exception with the failure message' do
        expect { importer.import }.to raise_error(/Error importing instance HRID: Something went wrong/)
      end
    end
  end
end
