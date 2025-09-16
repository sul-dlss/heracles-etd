# frozen_string_literal: true

require 'rails_helper'
require 'dry-monads'

# rubocop:disable RSpec/SubjectStub
RSpec.describe Marc::WriteStubRecord do
  include Dry::Monads[:result]

  subject(:writer) { described_class.new(druid:, record:) }

  let(:druid) { 'druid:cg532dg5405' }
  let(:marc_file) { 'spec/fixtures/marc/cg532dg5405/before_ils.marc' }
  let(:record) { MARC::Reader.new(marc_file).first }
  let(:marc_workspace) { Dir.mktmpdir('marc_workspace') }

  before do
    allow(Settings).to receive(:marc_workspace).and_return(marc_workspace)
  end

  after do
    FileUtils.rm_rf(marc_workspace)
  end

  describe '.send_to_folio' do
    before do
      allow(described_class).to receive(:new).and_return(writer)
      allow(writer).to receive(:send_to_folio)
    end

    it 'calls #send_to_folio on a new instance' do
      described_class.send_to_folio(druid:, record:)
      expect(writer).to have_received(:send_to_folio).once
    end
  end

  describe '#send_to_folio' do
    let(:instance_hrid) { 'a12345' }
    let(:job_status) { instance_double(FolioClient::JobStatus) }

    before { allow(FolioClient).to receive(:data_import).and_return(job_status) }

    context 'when success' do
      before do
        allow(job_status).to receive_messages(wait_until_complete: Success(), instance_hrids: Success([instance_hrid]))
      end

      it 'send marc record to folio and returns instance_hrid' do
        expect(writer.send_to_folio).to eq(instance_hrid)
        expect(job_status).to have_received(:wait_until_complete)
        expect(job_status).to have_received(:instance_hrids)
      end
    end

    context 'when failure' do
      let(:job_execution_id) { 'some_job_id' }

      before do
        allow(job_status).to receive_messages(wait_until_complete: Failure(), job_execution_id:)
      end

      it 'raises an exception with job_execution_id' do
        expect do
          writer.send_to_folio
        end.to raise_error('Record import failed.  See the import log in Folio for ' \
                           "#{job_execution_id} for more information. #{druid}")
      end
    end

    context 'when Folio returns a 404' do
      let(:job_execution_id) { 'some_job_id' }

      before do
        allow(FolioClient).to receive(:data_import).and_raise(FolioClient::ResourceNotFound)
        allow(Rails.logger).to receive(:error)
        allow(Honeybadger).to receive(:context)
      end

      it 'raises an exception and notifies' do
        expect { writer.send_to_folio }.to raise_error(FolioClient::ResourceNotFound)
        expect(Rails.logger).to have_received(:error)
        expect(Honeybadger).to have_received(:context).with(druid: 'druid:cg532dg5405').once
      end
    end
  end
end
# rubocop:enable RSpec/SubjectStub
