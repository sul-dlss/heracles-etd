# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CreateStubMarcRecordJob do
  subject(:job) { described_class.new }

  let(:druid) { 'druid:mj151qw9093' }
  let(:record) { MARC::Record.new }
  let(:general_error_msg) { "Error creating stub MARC record for #{druid}" }
  let(:cocina_model) do
    model = Cocina::Models.build({
                                   'label' => 'My ETD',
                                   'version' => 1,
                                   'type' => Cocina::Models::ObjectType.object,
                                   'externalIdentifier' => druid,
                                   'description' => {
                                     'title' => [{ 'value' => 'My ETD' }],
                                     'purl' => "https://purl.stanford.edu/#{druid.delete_prefix('druid:')}"
                                   },
                                   'administrative' => {
                                     'hasAdminPolicy' => Settings.etd_apo
                                   },
                                   'access' => {},
                                   identification: { sourceId: 'sul:1234' },
                                   'structural' => {}
                                 })
    Cocina::Models.with_metadata(model, 'abc123')
  end
  let(:object_client) do
    instance_double(Dor::Services::Client::Object,
                    find: cocina_model,
                    update: true)
  end

  before do
    allow(Honeybadger).to receive(:notify)
  end

  context 'when folio ILS' do
    let(:folio_instance_hrid) { 'in12345' }
    let(:submission) { Submission.find_by(druid:) }

    before do
      allow(Dor::Services::Client).to receive(:object).and_return(object_client)
      create(:submission, druid:)
    end

    describe '#perform' do
      before do
        allow(Marc::StubRecordCreator).to receive(:create).and_return(record)
        allow(Marc::WriteStubRecord).to receive(:send_to_folio).with(druid:, record:).and_return(folio_instance_hrid)
        job.perform(druid)
      end

      it 'asks the stub marc record creator to create a record and then send it to folio' do
        expect(Marc::StubRecordCreator).to have_received(:create).once
        expect(Marc::WriteStubRecord).to have_received(:send_to_folio).once
      end

      it 'updates the submission record in the database' do
        expect(submission.folio_instance_hrid).to eq folio_instance_hrid
        expect(submission.ils_record_created_at.to_date).to eq Time.zone.now.to_date
      end

      it 'adds identityMetadata with the folio_instance_hrid' do
        expect(object_client).to have_received(:update).once.with(params:
          Cocina::Models::DROWithMetadata.new({
                                                access: { view: 'dark', download: 'none' },
                                                administrative: { hasAdminPolicy: Settings.etd_apo },
                                                externalIdentifier: druid,
                                                identification: {
                                                  catalogLinks: [
                                                    { catalog: 'folio', catalogRecordId: folio_instance_hrid,
                                                      refresh: true }
                                                  ],
                                                  sourceId: 'sul:1234'
                                                },
                                                label: 'My ETD',
                                                type: Cocina::Models::ObjectType.object,
                                                version: 1,
                                                description: {
                                                  title: [{ value: 'My ETD' }],
                                                  purl: "https://purl.stanford.edu/#{druid.delete_prefix('druid:')}"
                                                },
                                                structural: {},
                                                lock: 'abc123'
                                              }))
      end
    end
  end
end
