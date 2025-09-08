# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Cocina::FileSetsGenerator do
  subject(:file_sets) { described_class.file_sets(submission:, dro_version: 1) }

  let(:submission) do
    create(:submission, :submitted, :with_dissertation_file, :with_augmented_dissertation_file,
           :with_supplemental_files, :with_permission_files, druid:)
  end

  let(:druid) { 'druid:xx999xx0021' }

  before do
    allow(SecureRandom).to receive(:uuid).and_return('bc4d50ef-fedb-4174-a346-d987d78b5bd0',
                                                     'fa870edf-bcf0-4618-ae9d-ab7d405c23ba',
                                                     '1a652fec-9f0e-4683-b7d6-2abdcc27085e',
                                                     '9e144086-2a5b-4bda-9504-acfe7e90480a',
                                                     'bab9ab2b-c690-4e1d-8673-65c974dabf7b',
                                                     '36cd36f2-2622-4faf-9f80-fd5bcfa11957')
  end

  it 'generates file sets' do
    expect(file_sets).to eq(
      [{ type: Cocina::Models::FileSetType.file,
         label: 'Body of dissertation (as submitted)',
         externalIdentifier: 'xx999xx0021_1',
         version: 1,
         structural:
   { contains:
     [{ type: Cocina::Models::ObjectType.file,
        externalIdentifier: 'https://cocina.sul.stanford.edu/file/xx999xx0021-1/bc4d50ef-fedb-4174-a346-d987d78b5bd0',
        label: 'dissertation.pdf',
        filename: 'dissertation.pdf',
        version: 1,
        hasMessageDigests:
        [{ type: 'sha1', digest: 'b2836ab9492bb89fa288ae0f4681193b124373a1' },
         { type: 'md5', digest: 'a5f7680e1675473fd129210f07408370' }],
        access: { view: 'world', download: 'world' },
        administrative: { publish: false, shelve: false, sdrPreserve: true },
        size: 14_544,
        hasMimeType: 'application/pdf' }] } },
       { type: Cocina::Models::FileSetType.file,
         label: 'Body of dissertation',
         externalIdentifier: 'xx999xx0021_2',
         version: 1,
         structural:
         { contains:
           [{ type: Cocina::Models::ObjectType.file,
              externalIdentifier: 'https://cocina.sul.stanford.edu/file/xx999xx0021-2/fa870edf-bcf0-4618-ae9d-ab7d405c23ba',
              label: 'dissertation-augmented.pdf',
              filename: 'dissertation-augmented.pdf',
              version: 1,
              hasMessageDigests:
              [{ type: 'sha1', digest: 'b2836ab9492bb89fa288ae0f4681193b124373a1' },
               { type: 'md5', digest: 'a5f7680e1675473fd129210f07408370' }],
              access: { view: 'world', download: 'world' },
              administrative: { publish: true, shelve: true, sdrPreserve: true },
              size: 14_544,
              hasMimeType: 'application/pdf' }] } },
       { type: Cocina::Models::FileSetType.file,
         label: 'supplemental file',
         externalIdentifier: 'xx999xx0021_3',
         version: 1,
         structural:
         { contains:
           [{ type: Cocina::Models::ObjectType.file,
              externalIdentifier: 'https://cocina.sul.stanford.edu/file/xx999xx0021-3/1a652fec-9f0e-4683-b7d6-2abdcc27085e',
              label: 'supplémental_1.pdf',
              filename: 'supplémental_1.pdf',
              version: 1,
              hasMessageDigests:
              [{ type: 'sha1', digest: 'b2836ab9492bb89fa288ae0f4681193b124373a1' },
               { type: 'md5', digest: 'a5f7680e1675473fd129210f07408370' }],
              access: { view: 'world', download: 'world' },
              administrative: { publish: true, shelve: true, sdrPreserve: true },
              size: 14_544,
              hasMimeType: 'application/pdf' }] } },
       { type: Cocina::Models::FileSetType.file,
         label: 'supplemental file',
         externalIdentifier: 'xx999xx0021_4',
         version: 1,
         structural:
         { contains:
           [{ type: Cocina::Models::ObjectType.file,
              externalIdentifier: 'https://cocina.sul.stanford.edu/file/xx999xx0021-4/9e144086-2a5b-4bda-9504-acfe7e90480a',
              label: 'supplemental_2.pdf',
              filename: 'supplemental_2.pdf',
              version: 1,
              hasMessageDigests:
              [{ type: 'sha1', digest: 'b2836ab9492bb89fa288ae0f4681193b124373a1' },
               { type: 'md5', digest: 'a5f7680e1675473fd129210f07408370' }],
              access: { view: 'world', download: 'world' },
              administrative: { publish: true, shelve: true, sdrPreserve: true },
              size: 14_544,
              hasMimeType: 'application/pdf' }] } },
       { type: Cocina::Models::FileSetType.file,
         label: 'permission file',
         externalIdentifier: 'xx999xx0021_5',
         version: 1,
         structural:
         { contains:
           [{ type: Cocina::Models::ObjectType.file,
              externalIdentifier: 'https://cocina.sul.stanford.edu/file/xx999xx0021-5/bab9ab2b-c690-4e1d-8673-65c974dabf7b',
              label: 'permission_1.pdf',
              filename: 'permission_1.pdf',
              version: 1,
              hasMessageDigests:
              [{ type: 'sha1', digest: 'c9fbb6eaf4549da5a798e50eeb376b167042db9a' },
               { type: 'md5', digest: 'f7169731f4c163f98eed35e1be12a209' }],
              access: { view: 'world', download: 'world' },
              administrative: { publish: false, shelve: false, sdrPreserve: true },
              size: 1634,
              hasMimeType: 'application/pdf' }] } },
       { type: Cocina::Models::FileSetType.file,
         label: 'permission file',
         externalIdentifier: 'xx999xx0021_6',
         version: 1,
         structural:
         { contains:
           [{ type: Cocina::Models::ObjectType.file,
              externalIdentifier: 'https://cocina.sul.stanford.edu/file/xx999xx0021-6/36cd36f2-2622-4faf-9f80-fd5bcfa11957',
              label: 'permission_2.pdf',
              filename: 'permission_2.pdf',
              version: 1,
              hasMessageDigests:
              [{ type: 'sha1', digest: 'c9fbb6eaf4549da5a798e50eeb376b167042db9a' },
               { type: 'md5', digest: 'f7169731f4c163f98eed35e1be12a209' }],
              access: { view: 'world', download: 'world' },
              administrative: { publish: false, shelve: false, sdrPreserve: true },
              size: 1634,
              hasMimeType: 'application/pdf' }] } }]
    )
  end
end
