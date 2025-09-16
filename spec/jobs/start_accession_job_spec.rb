# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StartAccessionJob do
  subject(:job) { described_class.new }

  let(:submission) do
    create(:submission, :submitted, :with_dissertation_file, :with_augmented_dissertation_file,
           :with_supplemental_files, :with_permission_files)
  end

  let(:druid) { submission.druid }
  let(:existing_dro) do
    Cocina::Models::DRO.new(
      externalIdentifier: druid,
      version: 1,
      type: Cocina::Models::ObjectType.object,
      label: 'dro label',
      description: {
        title: [{ value: 'dro label' }],
        purl: "https://purl.stanford.edu/#{druid.delete_prefix('druid:')}",
        contributor: [
          {
            name: [
              {
                value: 'Pretender, Student'
              }
            ],
            type: 'person',
            status: 'primary',
            role: [
              {
                value: 'author'
              }
            ],
            identifier: [
              {
                value: 'https://orcid.org/0000-0002-2100-6108'
              }
            ]
          }
        ]
      },
      identification: {
        sourceId: 'some:source_id'
      },
      administrative: {
        hasAdminPolicy: 'druid:dd999df4567'
      },
      access: {},
      structural: {}
    )
  end
  let(:content_dir) { Dir.mktmpdir('content') }
  let(:druid_tools) { instance_double(DruidTools::Druid, content_dir:) }
  let(:object_client) { instance_double(Dor::Services::Client::Object, version: version_client, refresh_descriptive_metadata_from_ils: true, find: existing_dro, update: true) }
  let(:version_client) { instance_double(Dor::Services::Client::ObjectVersion, close: nil, current: 1) }

  before do
    allow(Sdr::AdministrativeTagCreator).to receive(:create)
    allow(Dor::Services::Client).to receive(:object).and_return(object_client)
    allow(DruidTools::Druid).to receive(:new).and_return(druid_tools)
    allow(Sdr::ReleaseTagger).to receive(:tag)
  end

  after do
    FileUtils.rm_rf(content_dir)
  end

  describe '#perform' do
    it 'starts accessioning' do
      job.perform(druid)

      expect(File.exist?(File.join(content_dir, 'dissertation.pdf'))).to be true
      expect(File.exist?(File.join(content_dir, 'dissertation-augmented.pdf'))).to be true
      expect(File.exist?(File.join(content_dir, 'supplémental_1.pdf'))).to be true
      expect(File.exist?(File.join(content_dir, 'supplemental_2.pdf'))).to be true
      expect(File.exist?(File.join(content_dir, 'permission_1.pdf'))).to be true
      expect(File.exist?(File.join(content_dir, 'permission_2.pdf'))).to be true

      expect(object_client).to have_received(:update) do |params:|
        expect(params.access).to be_present
        expect(params.structural).to be_present
        expect(params.description.to_h[:form].first).to include(
          {
            source: {
              note: [],
              value: 'DataCite resource types'
            },
            type: 'resource type',
            value: 'Dissertation'
          }
        )
        expect(params.description.to_h[:form].second).to include(
          {
            source: {
              note: [],
              value: 'Stanford self-deposit resource types'
            },
            type: 'resource type',
            structuredValue: [
              {
                appliesTo: [],
                groupedValue: [],
                identifier: [],
                note: [],
                parallelValue: [],
                structuredValue: [],
                type: 'subtype',
                value: 'Academic thesis'
              }
            ]
          }
        )
        expect(params.identification.doi).to eq("10.80343/#{druid.delete_prefix('druid:')}")
        # normalizes the ORCID identifier for the author
        expect(params.description.contributor.first.identifier.first.to_h).to eq(
          {
            appliesTo: [],
            groupedValue: [],
            identifier: [],
            note: [],
            parallelValue: [],
            source: {
              note: [],
              uri: 'https://orcid.org'
            },
            structuredValue: [],
            type: 'ORCID',
            value: '0000-0002-2100-6108'
          }
        )
      end

      expect(Sdr::AdministrativeTagCreator).to have_received(:create).with(submission)
      expect(submission.reload.accessioning_started_at).not_to be_nil
      expect(version_client).to have_received(:close)

      expect(Sdr::ReleaseTagger).to have_received(:tag).with(druid:).once
    end
  end
end
