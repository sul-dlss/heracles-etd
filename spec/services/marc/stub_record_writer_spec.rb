# frozen_string_literal: true

require 'rails_helper'
require 'dry-monads'

# rubocop:disable RSpec/SubjectStub
RSpec.describe Marc::StubRecordWriter do
  include Dry::Monads[:result]

  subject(:writer) { described_class.new(druid:, record:) }

  let(:druid) { 'druid:cg532dg5405' }
  let(:job_execution_id) { 'some_job_id' }
  let(:marc_file) { 'spec/fixtures/marc/cg532dg5405/before_ils.marc' }
  let(:record) { MARC::Reader.new(marc_file).first }
  let(:marc_workspace) { Dir.mktmpdir('marc_workspace') }

  before do
    allow(Settings).to receive(:marc_workspace).and_return(marc_workspace)
  end

  after do
    FileUtils.rm_rf(marc_workspace)
  end

  describe '.write_to_catalog' do
    before do
      allow(described_class).to receive(:new).and_return(writer)
      allow(writer).to receive(:write_to_catalog)
    end

    it 'calls #write_to_catalog on a new instance' do
      described_class.write_to_catalog(druid:, record:)
      expect(writer).to have_received(:write_to_catalog).once
    end
  end

  describe '#write_to_catalog' do
    let(:job_status) { instance_double(FolioClient::JobStatus, job_execution_id:) }

    before { allow(FolioClient).to receive(:data_import).and_return(job_status) }

    context 'when success' do
      before do
        allow(job_status).to receive_messages(wait_until_complete: Success())
      end

      it 'writes the record to folio and returns the job ID' do
        expect(writer.write_to_catalog).to eq(job_execution_id)
        expect(job_status).to have_received(:wait_until_complete)
      end
    end

    context 'when failure' do
      before do
        allow(job_status).to receive_messages(wait_until_complete: Failure())
      end

      it 'raises an exception with job_execution_id' do
        expect do
          writer.write_to_catalog
        end.to raise_error(/Error writing stub MARC record for .+: see Folio import log for job/)
      end
    end

    context 'when catalog returns a 404 when running data import' do
      before do
        allow(FolioClient).to receive(:data_import).and_raise(FolioClient::ResourceNotFound)
        allow(Rails.logger).to receive(:error)
        allow(Honeybadger).to receive(:context)
      end

      it 'raises an exception and notifies' do
        expect { writer.write_to_catalog }.to raise_error(FolioClient::ResourceNotFound)
        expect(Rails.logger).to have_received(:error)
                            .with(/FolioClient::ResourceNotFound: .* Error sending stub MARC record to FOLIO/).once
        expect(Honeybadger).to have_received(:context).with(druid: 'druid:cg532dg5405').once
      end
    end
  end
end
# rubocop:enable RSpec/SubjectStub
