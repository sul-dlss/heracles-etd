# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Marc::StubRecordPipeline do
  subject(:pipeline) { described_class.new(druid: submission.druid) }

  let(:submission) { create(:submission) }

  # rubocop:disable RSpec/SubjectStub
  describe '.run!' do
    before do
      allow(described_class).to receive(:new).and_return(pipeline)
      allow(pipeline).to receive(:run!)
    end

    it 'initializes a new instance and calls #run!' do
      described_class.run!(druid: submission.druid)
      expect(pipeline).to have_received(:run!).once
    end
  end
  # rubocop:enable RSpec/SubjectStub

  describe '#run!' do
    let(:cocina_object) do
      Cocina::Models.build({
                             'label' => 'My ETD',
                             'version' => 1,
                             'type' => Cocina::Models::ObjectType.object,
                             'externalIdentifier' => submission.druid,
                             'description' => {
                               'title' => [{ 'value' => 'My ETD' }],
                               'purl' => "https://purl.stanford.edu/#{submission.druid.delete_prefix('druid:')}"
                             },
                             'administrative' => {
                               'hasAdminPolicy' => Settings.etd_apo
                             },
                             'access' => {},
                             identification: { sourceId: 'sul:1234' },
                             'structural' => {}
                           })
    end
    let(:record) { MARC::Record.new }

    before do
      allow(Marc::StubRecordGenerator).to receive(:generate).and_return(record)
      allow(Marc::StubRecordWriter).to receive(:write_to_catalog).and_return('some_job_id')
      allow(Marc::CatalogIdentifierImporter).to receive(:import).and_return('a987654321')
      allow(Honeybadger).to receive(:context)
      allow(Dor::Services::Client).to receive(:object)
                                  .and_return(
                                    instance_double(Dor::Services::Client::Object, find: cocina_object, update: true)
                                  )
    end

    it 'generates a stub MARC record' do
      pipeline.run!
      expect(Marc::StubRecordGenerator).to have_received(:generate).with(druid: submission.druid).once
    end

    it 'writes the stub MARC record to the catalog' do
      pipeline.run!
      expect(Marc::StubRecordWriter).to have_received(:write_to_catalog).with(druid: submission.druid, record:).once
    end

    it 'persists the catalog record job ID to the database' do
      pipeline.run!
      expect(submission.reload.catalog_record_job_id).to eq('some_job_id')
    end

    it 'imports the catalog identifier' do
      pipeline.run!
      expect(Marc::CatalogIdentifierImporter).to have_received(:import).with(submission:).once
    end

    it 'sets the folio_instance_hrid in Honeybadger context' do
      pipeline.run!
      expect(Honeybadger).to have_received(:context).with(folio_instance_hrid: 'a987654321').once
    end

    it 'updates the submission item in SDR with a catalog link to the Folio instance' do
      pipeline.run!
      expect(Dor::Services::Client).to have_received(:object).with(submission.druid).at_least(:once)
      expect(Dor::Services::Client.object(submission.druid)).to have_received(:update).with(
        params: Cocina::Models::DRO.new(
          {
            access: {
              view: 'dark', download: 'none'
            },
            administrative: { hasAdminPolicy: Settings.etd_apo },
            externalIdentifier: submission.druid,
            identification: {
              catalogLinks: [
                { catalog: 'folio', catalogRecordId: 'a987654321', refresh: true }
              ],
              sourceId: 'sul:1234'
            },
            label: 'My ETD',
            type: Cocina::Models::ObjectType.object,
            version: 1,
            description: {
              title: [{ value: 'My ETD' }],
              purl: "https://purl.stanford.edu/#{submission.druid.delete_prefix('druid:')}"
            },
            structural: {}
          }
        )
      ).once
    end

    context 'when the stub record has already been written' do
      let(:submission) { create(:submission, :stub_record_in_ils) }

      it 'skips generating the stub record' do
        pipeline.run!
        expect(Marc::StubRecordGenerator).not_to have_received(:generate)
      end

      it 'skips writing the stub record to the catalog' do
        pipeline.run!
        expect(Marc::StubRecordWriter).not_to have_received(:write_to_catalog)
      end

      it 'skips persisting the catalog record job ID to the database' do
        pipeline.run!
        expect(submission.reload.catalog_record_job_id).not_to eq('some_job_id')
      end
    end

    context 'when the submission cannot be found' do
      let(:submission) { build(:submission) }

      it 'raises an error if the submission cannot be found' do
        expect { pipeline.run! }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
