# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CreateEmbargo do
  let(:submission) do
    create(:submission, :submitted, last_registrar_action_at:, last_reader_action_at:, submitted_at:, embargo:)
  end
  let(:last_registrar_action_at) { last_reader_action_at + 30 }
  let(:last_reader_action_at) { Time.zone.now - 3600 }
  let(:submitted_at) { Time.zone.now - 7200 }
  let(:embargo) { '6 months' }

  describe '.call' do
    let(:instance) { instance_double(described_class, call: nil) }

    before do
      allow(described_class).to receive(:new).and_return(instance)
    end

    it 'invokes #call on a new instance' do
      described_class.call(submission.druid, submission.embargo_release_date)
      expect(instance).to have_received(:call).once
    end
  end

  describe '#call' do
    subject(:embargo_creator) { described_class.new(submission.druid, submission.embargo_release_date) }

    let(:cocina_item) do
      Cocina::Models.with_metadata(
        Cocina::Models.build(
          {
            label: 'My ETD',
            version: 1,
            type: Cocina::Models::ObjectType.object,
            description: {
              title: [{ value: 'My ETD' }],
              purl: "https://purl.stanford.edu/#{submission.druid.delete_prefix('druid:')}"
            },
            administrative: {
              hasAdminPolicy: RegisterService::ETD_APO_DRUID
            },
            externalIdentifier: submission.druid,
            access: {},
            structural: {},
            identification: { sourceId: 'sul:1234' }
          }
        ),
        'abc123'
      )
    end
    let(:object_client) do
      instance_double(Dor::Services::Client::Object, find: cocina_item, update: true)
    end

    before do
      allow(Dor::Services::Client).to receive(:object).and_return(object_client)
    end

    context 'when embargoed 6 months' do
      let(:expected_embargo_date) { last_registrar_action_at.to_date.months_since(6).beginning_of_day.to_datetime }

      it 'creates the embargo' do
        embargo_creator.call
        expect(object_client).to have_received(:update)
          .with(params: cocina_object_with(
            access: {
              view: 'dark',
              download: 'none',
              embargo: {
                view: 'world',
                download: 'world',
                releaseDate: expected_embargo_date
              }
            }
          ))
      end
    end

    context 'when not embargoed' do
      let(:embargo) { 'immediately' }

      it 'does not create embargoMetadata' do
        embargo_creator.call
        expect(object_client).not_to have_received(:update)
      end
    end

    context 'when the embargo date is today' do
      let(:last_reader_action_at) { Time.zone.now.months_ago(5) }
      let(:last_registrar_action_at) { last_reader_action_at + 30 }
      let(:submitted_at) { Time.zone.now.months_ago(6) }

      it 'does not create embargoMetadata if the embargo date is today' do
        embargo_creator.call
        expect(object_client).not_to have_received(:update)
      end
    end

    # NOTE: see Submission#embargo_release_date
    context 'when the embargo date is today and during the weird time window' do
      Timecop.freeze(Time.new(2023, 2, 3, 15, 59, 0, '-08:00')) do
        let(:last_reader_action_at) { Time.zone.now.months_ago(6) }
        let(:last_registrar_action_at) { last_reader_action_at + 30 }
        let(:submitted_at) { Time.zone.now.months_ago(6) }

        it 'does not create embargoMetadata if the embargo date is today' do
          embargo_creator.call
          expect(object_client).not_to have_received(:update)
        end
      end
    end

    context 'when the embargo date is in the past' do
      let(:last_reader_action_at) { Time.zone.now.years_ago(1) }
      let(:last_registrar_action_at) { last_reader_action_at + 30 }
      let(:submitted_at) { Time.zone.now.years_ago(1) }

      it 'does not create embargoMetadata if the embargo date is in the past' do
        embargo_creator.call
        expect(object_client).not_to have_received(:update)
      end
    end
  end
end
