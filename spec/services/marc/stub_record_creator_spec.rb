# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Marc::StubRecordCreator do
  subject(:creator) { described_class.new(druid:) }

  let(:druid) { 'druid:cg532dg5405' }
  let(:orcid) { 'https://orcid.org/0000-0002-2100-6108' }
  let(:abstract) do
    <<~ABSTRACT
      Convex optimization has been well-studied as a mathematical topic for
      more than a century, and has been applied in practice in many application
      areas for about a half century in fields including control,
      finance, signal processing, data mining, and machine learning.
      This thesis focuses on several topics involving convex optimization,
      with the specific application of machine learning.
    ABSTRACT
  end
  let(:submission) do
    Submission.create!(
      druid:,
      dissertation_id: '0000007573',
      degreeconfyr: 2020,
      submitted_at: Time.zone.parse('2020-04-08'),
      name: 'Park, Youngsuk',
      title: 'TOPICS IN CONVEX OPTIMIZATION FOR MACHINE LEARNING',
      degree: 'Ph.D.',
      abstract:,
      department: 'Electrical Engineering',
      schoolname: 'School of Engineering',
      etd_type: 'Dissertation',
      sunetid: 'oprahw'
    )
  end

  before do
    submission.readers.create(
      [
        {
          name: 'Boyd, Stephen',
          readerrole: 'Advisor',
          position: 1
        },
        {
          name: 'Weissman, Tsachy',
          readerrole: 'Reader',
          position: 3
        },
        {
          name: 'Leskovec, Jure',
          readerrole: 'Reader',
          position: 2
        }
      ]
    )
    # Set date to match that in ETD fixture
    allow(Time.zone).to receive(:now).and_return(Time.new(2020, 4, 17, 10)) # rubocop:disable Rails/TimeZone
  end

  describe '.create' do
    before do
      allow(described_class).to receive(:new).and_return(creator)
      allow(creator).to receive(:create) # rubocop:disable RSpec/SubjectStub
    end

    it 'calls #create on a new instance' do
      described_class.create(druid:)
      expect(creator).to have_received(:create).once # rubocop:disable RSpec/SubjectStub
    end
  end

  describe '#create' do
    let(:marc_record) { creator.create }
    let(:submission) do
      Submission.create!(
        druid:,
        orcid:,
        dissertation_id: '0000007573',
        degreeconfyr: 2020,
        submitted_at: Time.zone.parse('2020-04-08'),
        name: 'Park, Youngsuk III',
        title: 'TOPICS IN CONVEX OPTIMIZATION FOR MACHINE LEARNING',
        degree: 'Ph.D.',
        abstract:,
        department:,
        schoolname: school,
        etd_type: 'Dissertation',
        sunetid: 'oprahw'
      )
    end
    let(:school) { 'School of Engineering' }
    let(:department) { 'Electrical Engineering' }

    describe 'leader' do
      let(:leader) { marc_record.leader }

      it 'has bytes set as expected' do
        expect(leader[5]).to eq 'n'
        expect(leader[6]).to eq 'a'
        expect(leader[7]).to eq 'm'
        expect(leader[9]).to eq 'a'
        expect(leader[17]).to eq '3'
        expect(leader[18]).to eq 'i'
      end
    end

    describe '008' do
      let(:field008) { marc_record.fields('008').first }
      let(:publication_year) { creator.send(:publication_year) }
      let(:copyright_year) { creator.send(:copyright_year) }
      let(:today) { Time.zone.now.strftime('%y%m%d') }

      it 'has bytes set as expected' do
        expect(field008.value).to eq("#{today}t#{publication_year}#{copyright_year}cau     om    000 0 eng d")
      end
    end

    describe '001' do
      let(:field001) { marc_record.fields('001').first }

      it 'contains bare_druid with dor prefix' do
        expect(field001.value).to eq("dor#{druid.sub('druid:', '')}")
      end
    end

    describe '006' do
      let(:field006) { marc_record.fields('006').first }

      it 'has bytes set as expected' do
        expect(field006.value).to eq('m     o  d        ')
      end
    end

    describe '007' do
      let(:field007) { marc_record.fields('007').first }

      it 'has bytes set as expected' do
        expect(field007.value).to eq('cr un')
      end
    end

    describe '024' do
      let(:field024) { marc_record.fields('024').first }

      it 'has one 024 field' do
        expect(marc_record.fields('024').count).to eq(1)
      end

      it 'has expected first and second indicators' do
        expect(field024.indicator1).to eq('7')
        expect(field024.indicator2).to eq(' ')
      end

      it 'has subfields a & 2 in order' do
        expect(field024.subfields.map(&:code)).to eq(%w[a 2])
      end

      it 'subfield a contains DOI value' do
        subfields_a = field024.subfields.select { |subfield| subfield.code == 'a' }
        expect(subfields_a.count).to eq(1)
        expect(subfields_a.first.value).to eq('10.80343/cg532dg5405')
      end

      it 'subfield 2 contains DOI string' do
        subfields_two = field024.subfields.select { |subfield| subfield.code == '2' }
        expect(subfields_two.count).to eq(1)
        expect(subfields_two.first.value).to eq('doi')
      end
    end

    describe '040' do
      let(:field040) { marc_record.fields('040').first }

      it 'has one 040 field' do
        expect(marc_record.fields('040').count).to eq(1)
      end

      it 'has first and second indicators blank' do
        expect(field040.indicator1).to eq(' ')
        expect(field040.indicator2).to eq(' ')
      end

      it 'has subfields a, b, e, c in order' do
        expect(field040.subfields.map(&:code)).to eq(%w[a b e c])
      end

      it 'subfield a contains CSt' do
        subfields_a = field040.subfields.filter { |subfield| subfield.code == 'a' }
        expect(subfields_a.count).to eq(1)
        expect(subfields_a.first.value).to eq('CSt')
      end

      it 'subfield b contains eng' do
        subfields_b = field040.subfields.filter { |subfield| subfield.code == 'b' }
        expect(subfields_b.count).to eq(1)
        expect(subfields_b.first.value).to eq('eng')
      end

      it 'subfield e contains rda' do
        subfields_e = field040.subfields.filter { |subfield| subfield.code == 'e' }
        expect(subfields_e.count).to eq(1)
        expect(subfields_e.first.value).to eq('rda')
      end

      it 'subfield c contains CSt' do
        subfields_c = field040.subfields.filter { |subfield| subfield.code == 'c' }
        expect(subfields_c.count).to eq(1)
        expect(subfields_c.first.value).to eq('CSt')
      end
    end

    describe '100 author field' do
      let(:field100) { marc_record.fields('100').first }

      it 'has one 100 field' do
        expect(marc_record.fields('100').count).to eq(1)
      end

      it 'has first indicator 1, second indicator blank' do
        expect(field100.indicator1).to eq('1')
        expect(field100.indicator2).to eq(' ')
      end

      it 'subfield a contains raw name from submission with trailing comma' do
        subfields_a = field100.subfields.filter { |subfield| subfield.code == 'a' }
        expect(subfields_a.count).to eq(1)
        expect(subfields_a.first.value).to eq("#{submission.name},")
      end

      it 'subfield e contains "author."' do
        subfields_e = field100.subfields.filter { |subfield| subfield.code == 'e' }
        expect(subfields_e.count).to eq(1)
        expect(subfields_e.first.value).to eq('author.')
      end

      it 'subfield 1 contains fully-qualified ORCID ID of author' do
        subfields_one = field100.subfields.select { |subfield| subfield.code == '1' }
        expect(subfields_one.count).to eq(1)
        expect(subfields_one.first.value).to eq('https://orcid.org/0000-0002-2100-6108')
      end

      context 'when only a name suffix is present' do
        let(:submission) do
          Submission.create!(
            druid:,
            dissertation_id: '0000007573',
            degreeconfyr: 2020,
            submitted_at: Time.zone.parse('2020-04-08'),
            name: 'Park, Youngsuk',
            suffix: 'III',
            title: 'TOPICS IN CONVEX OPTIMIZATION FOR MACHINE LEARNING',
            degree: 'Ph.D.',
            abstract:,
            department: 'Electrical Engineering',
            schoolname: 'School of Engineering',
            etd_type: 'Dissertation',
            sunetid: 'oprahw'
          )
        end
        let(:subfields_c) { field100.subfields.filter { |subfield| subfield.code == 'c' } }

        it 'single subfield c contains suffix followed by comma' do
          expect(subfields_c.count).to eq(1)
          expect(subfields_c.first.value).to eq('III,')
        end
      end

      context 'when only a name prefix is present' do
        let(:submission) do
          Submission.create!(
            druid:,
            dissertation_id: '0000007573',
            degreeconfyr: 2020,
            submitted_at: Time.zone.parse('2020-04-08'),
            name: 'Park, Youngsuk',
            prefix: 'Dr.',
            title: 'TOPICS IN CONVEX OPTIMIZATION FOR MACHINE LEARNING',
            degree: 'Ph.D.',
            abstract:,
            department: 'Electrical Engineering',
            schoolname: 'School of Engineering',
            etd_type: 'Dissertation',
            sunetid: 'oprahw'
          )
        end
        let(:subfields_c) { field100.subfields.filter { |subfield| subfield.code == 'c' } }

        it 'single subfield c contains prefix followed by comma' do
          expect(subfields_c.count).to eq(1)
          expect(subfields_c.first.value).to eq('Dr.,')
        end
      end

      context 'when both prefix and suffix are present' do
        let(:submission) do
          Submission.create!(
            druid:,
            dissertation_id: '0000007573',
            degreeconfyr: 2020,
            submitted_at: Time.zone.parse('2020-04-08'),
            name: 'Hernandez, Fidel',
            prefix: 'Mr.',
            suffix: 'III',
            title: 'TOPICS IN CONVEX OPTIMIZATION FOR MACHINE LEARNING',
            degree: 'Ph.D.',
            abstract:,
            department: 'Electrical Engineering',
            schoolname: 'School of Engineering',
            etd_type: 'Dissertation',
            sunetid: 'oprahw'
          )
        end
        let(:subfields_c) { field100.subfields.filter { |subfield| subfield.code == 'c' } }

        it 'one subfield c each for suffix and prefix values followed by comma' do
          expect(subfields_c.count).to eq(2)
          expect(subfields_c.first.value).to eq('III,')
          expect(subfields_c.last.value).to eq('Mr.,')
        end
      end
    end

    describe '245 title field' do
      let(:field245) { marc_record.fields('245').first }
      let(:subfields_c) { field245.subfields.filter { |subfield| subfield.code == 'c' } }

      it 'has one 245 field' do
        expect(marc_record.fields('245').count).to eq(1)
      end

      it 'has first indicator 1, second indicator blank' do
        expect(field245.indicator1).to eq('1')
        expect(field245.indicator2).to eq('0')
      end

      it 'has 2 subfields' do
        expect(field245.subfields.count).to eq(2)
      end

      it 'subfield a contains title from submission with trailing slash' do
        subfields_a = field245.subfields.filter { |subfield| subfield.code == 'a' }
        expect(subfields_a.count).to eq(1)
        expect(subfields_a.first.value).to eq("#{submission.title} /")
      end

      it 'subfield c contains author name formatted last name first' do
        expect(subfields_c.count).to eq(1)
        expect(subfields_c.first.value).to eq(creator.send(:format_aacr2,
                                                           creator.send(:format_full_name, submission.name)))
      end

      context 'when author name has a suffix' do
        let(:submission) do
          Submission.create!(
            druid:,
            dissertation_id: '0000007573',
            degreeconfyr: 2020,
            submitted_at: Time.zone.parse('2020-04-08'),
            name: 'Park, Youngsuk',
            suffix: 'III',
            title: 'TOPICS IN CONVEX OPTIMIZATION FOR MACHINE LEARNING',
            degree: 'Ph.D.',
            abstract:,
            department: 'Electrical Engineering',
            schoolname: 'School of Engineering',
            etd_type: 'Dissertation',
            sunetid: 'oprahw'
          )
        end

        it 'suffix goes after full name' do
          expect(subfields_c.count).to eq(1)
          expected_full_name = creator.send(:format_aacr2,
                                            "#{creator.send(:format_full_name, submission.name)}, #{submission.suffix}")
          expect(subfields_c.first.value).to eq(expected_full_name)
        end
      end

      context 'when author name has a prefix' do
        let(:submission) do
          Submission.create!(
            druid:,
            dissertation_id: '0000007573',
            degreeconfyr: 2020,
            submitted_at: Time.zone.parse('2020-04-08'),
            name: 'Park, Youngsuk',
            prefix: 'Dr.',
            title: 'TOPICS IN CONVEX OPTIMIZATION FOR MACHINE LEARNING',
            degree: 'Ph.D.',
            abstract:,
            department: 'Electrical Engineering',
            schoolname: 'School of Engineering',
            etd_type: 'Dissertation',
            sunetid: 'oprahw'
          )
        end

        it 'prefix goes before full name' do
          expect(subfields_c.count).to eq(1)
          expected_full_name = creator.send(:format_aacr2,
                                            "#{submission.prefix} #{creator.send(:format_full_name, submission.name)}")
          expect(subfields_c.first.value).to eq(expected_full_name)
        end
      end

      context 'when author name has a suffix and a prefix' do
        let(:submission) do
          Submission.create!(
            druid:,
            dissertation_id: '0000007573',
            degreeconfyr: 2020,
            submitted_at: Time.zone.parse('2020-04-08'),
            name: 'Hernandez, Fidel',
            prefix: 'Mr.',
            suffix: 'III',
            title: 'TOPICS IN CONVEX OPTIMIZATION FOR MACHINE LEARNING',
            degree: 'Ph.D.',
            abstract:,
            department: 'Electrical Engineering',
            schoolname: 'School of Engineering',
            etd_type: 'Dissertation',
            sunetid: 'oprahw'
          )
        end

        it 'has prefix and suffix in correct places' do
          expect(subfields_c.count).to eq(1)
          name = creator.send(:format_full_name, submission.name)
          expected_full_name = creator.send(:format_aacr2, "#{submission.prefix} #{name}, #{submission.suffix}")
          expect(subfields_c.first.value).to eq(expected_full_name)
        end
      end
    end

    describe '264 fields for publication and copyright' do
      let(:fields264) { marc_record.fields('264') }

      it 'has two 264 fields' do
        expect(fields264.size).to eq 2
      end

      context 'when publication with indicator 2 = 1' do
        let(:publication264) { fields264.find { |field| field.indicator2 == '1' } }
        let(:subfields) { publication264.subfields }

        it 'has first indicator 1 blank' do
          expect(publication264.indicator1).to eq(' ')
        end

        it 'has 3 subfields, a, b, c' do
          expect(subfields.count).to eq(3)
          expect(subfields.map(&:code)).to eq(%w[a b c])
        end

        it 'subfield a has location (formatted for a CATALOG CARD)' do
          expect(subfields.first.value).to eq('[Stanford, California] :')
        end

        it 'subfield b has publisher (formatted for a CATALOG CARD)' do
          expect(subfields.second.value).to eq('[Stanford University],')
        end

        it 'subfield c has degree year (formatted for a CATALOG CARD - trailing period.)' do
          expect(subfields.last.value).to eq('2020.')
        end
      end

      context 'when copyright field with indicator 2 = 4' do
        let(:copyright264) { fields264.find { |field| field.indicator2 == '4' } }
        let(:subfields) { copyright264.subfields }

        it 'has first indicator 1 blank' do
          expect(copyright264.indicator1).to eq(' ')
        end

        it 'has 1 subfield' do
          expect(subfields.count).to eq(1)
        end

        it 'subfield a has copyright year from submitted_at' do
          expect(subfields.first.value).to eq('©2020')
        end

        context 'when submitted_at is not available, use degreeconfyr' do
          let(:submission) do
            Submission.create!(
              druid:,
              dissertation_id: '0000007573',
              degreeconfyr: 2024,
              name: 'Park, Youngsuk',
              title: 'TOPICS IN CONVEX OPTIMIZATION FOR MACHINE LEARNING',
              degree: 'Ph.D.',
              abstract:,
              department: 'Electrical Engineering',
              schoolname: 'School of Engineering',
              etd_type: 'Dissertation',
              sunetid: 'oprahw'
            )
          end

          it 'subfield a has copyright year from degreeconfyr' do
            expect(subfields.first.value).to eq('©2024')
          end
        end
      end
    end

    describe '300 field' do
      let(:field300) { marc_record.fields('300').first }

      it 'has one 300 field' do
        expect(marc_record.fields('300').count).to eq(1)
      end

      it 'has first and second indicators blank' do
        expect(field300.indicator1).to eq(' ')
        expect(field300.indicator2).to eq(' ')
      end

      it 'has subfield a only' do
        expect(field300.subfields.count).to eq(1)
        expect(field300.subfields.first.code).to eq('a')
      end

      it 'subfield a contains expected content' do
        expect(field300.subfields.first.value).to eq('1 online resource.')
      end
    end

    describe '336 field' do
      let(:field336) { marc_record.fields('336').first }

      it 'has one 336 field' do
        expect(marc_record.fields('336').count).to eq(1)
      end

      it 'has first and second indicators blank' do
        expect(field336.indicator1).to eq(' ')
        expect(field336.indicator2).to eq(' ')
      end

      it 'has subfields a, b, and 2' do
        expect(field336.subfields.map(&:code)).to eq(%w[a b 2])
      end

      it 'subfield a contains "text"' do
        expect(field336.subfields.first.value).to eq('text')
      end

      it 'subfield 2 contains "rdacontent"' do
        expect(field336.subfields.last.value).to eq('rdacontent')
      end
    end

    describe '337 field' do
      let(:field337) { marc_record.fields('337').first }

      it 'has one 337 field' do
        expect(marc_record.fields('337').count).to eq(1)
      end

      it 'has first and second indicators blank' do
        expect(field337.indicator1).to eq(' ')
        expect(field337.indicator2).to eq(' ')
      end

      it 'has subfields a, b, and 2' do
        expect(field337.subfields.count).to eq(3)
        expect(field337.subfields.map(&:code)).to eq(%w[a b 2])
      end

      it 'subfield a contains "computer"' do
        expect(field337.subfields.first.value).to eq('computer')
      end

      it 'subfield 2 contains "rdamedia"' do
        expect(field337.subfields.last.value).to eq('rdamedia')
      end
    end

    describe '338 field' do
      let(:field338) { marc_record.fields('338').first }

      it 'has one 338 field' do
        expect(marc_record.fields('338').count).to eq(1)
      end

      it 'has first and second indicators blank' do
        expect(field338.indicator1).to eq(' ')
        expect(field338.indicator2).to eq(' ')
      end

      it 'has subfields a, b, and 2' do
        expect(field338.subfields.count).to eq(3)
        expect(field338.subfields.map(&:code)).to eq(%w[a b 2])
      end

      it 'subfield a contains "online resource"' do
        expect(field338.subfields.first.value).to eq('online resource')
      end

      it 'subfield 2 contains "rdacarrier"' do
        expect(field338.subfields.last.value).to eq('rdacarrier')
      end
    end

    describe '500 field for submitted to' do
      let(:field500) { marc_record.fields('500').first }

      it 'has one 500 field' do
        expect(marc_record.fields('500').count).to eq(1)
      end

      it 'has first and second indicators blank' do
        expect(field500.indicator1).to eq(' ')
        expect(field500.indicator2).to eq(' ')
      end

      it 'has subfield a only' do
        expect(field500.subfields.count).to eq(1)
        expect(field500.subfields.first.code).to eq('a')
      end

      it 'subfield a contains "Submitted to the Department of (department)" (formatted for a CATALOG CARD)' do
        expect(field500.subfields.first.value)
          .to eq("Submitted to the Department of #{creator.send(:format_aacr2, submission.department)}")
      end

      context 'when department matches Business (or Education or Law)' do
        let(:submission) do
          Submission.create!(
            druid:,
            dissertation_id: '0000007573',
            degreeconfyr: 2020,
            submitted_at: Time.zone.parse('2020-04-08'),
            name: 'Park, Youngsuk',
            title: 'TOPICS IN CONVEX OPTIMIZATION FOR MACHINE LEARNING',
            degree: 'Ph.D.',
            abstract:,
            department: 'Business Administration',
            schoolname: 'Graduate School of Business',
            etd_type: 'Dissertation',
            sunetid: 'oprahw'
          )
        end
        let(:field500) { marc_record.fields('500').first }

        it 'subfield a contains "Submitted to the School of (department)" (formatted for a CATALOG CARD)' do
          expect(field500.subfields.first.value)
            .to eq("Submitted to the School of #{creator.send(:format_aacr2, submission.department)}")
        end
      end

      context 'when department is nil' do
        let(:submission) do
          Submission.create!(
            druid:,
            dissertation_id: '0000007573',
            degreeconfyr: 2020,
            submitted_at: Time.zone.parse('2020-04-08'),
            name: 'Park, Youngsuk',
            title: 'TOPICS IN CONVEX OPTIMIZATION FOR MACHINE LEARNING',
            degree: 'Ph.D.',
            abstract:,
            department: nil,
            schoolname: 'Graduate School of Business',
            etd_type: 'Dissertation',
            sunetid: 'oprahw'
          )
        end

        it 'there is no 500 field' do
          expect(marc_record.fields('500').count).to eq(0)
        end
      end
    end

    describe '502 field for thesis' do
      let(:field502) { marc_record.fields('502').first }

      it 'has one 502 field' do
        expect(marc_record.fields('502').count).to eq(1)
      end

      it 'has first and second indicators blank' do
        expect(field502.indicator1).to eq(' ')
        expect(field502.indicator2).to eq(' ')
      end

      it 'has subfields g, b, c, d in order' do
        expect(field502.subfields.map(&:code)).to eq(%w[g b c d])
      end

      it 'subfield g contains "Thesis"' do
        expect(field502.subfields.first.value).to eq('Thesis')
      end

      it 'subfield b contains degree field' do
        expect(field502.subfields[1].value).to eq(submission.degree.strip)
      end

      it 'subfield c contains "Stanford University"' do
        expect(field502.subfields[2].value).to eq('Stanford University')
      end

      it 'subfield d contains degree uear formatted for a CATALOG CARD' do
        expect(field502.subfields.last.value).to eq("#{submission.degreeconfyr}.")
      end
    end

    describe '520 field for abstract' do
      it 'has one 520 for the abstract' do
        expect(marc_record.fields('520').count).to eq(1)
      end

      it 'has the contents of the abstract as subfield a' do
        field = marc_record.fields('520').first
        expect(field['a']).to eq creator.send(:format_aacr2, abstract)
      end
    end

    describe '700 fields for readers' do
      before do
        submission.readers.create(
          [
            {
              name: 'Stark, Tony',
              readerrole: 'Outside Dissert Advisor (AC)',
              position: 4
            },
            {
              name: 'Marvel, Captain',
              readerrole: 'Doct Dissert Co-Adv (AC)',
              position: 5
            },
            {
              name: 'Woman, Wonder',
              readerrole: 'Doct Dissert Reader (AC)',
              position: 6
            },
            {
              name: 'Shoo, Mister',
              readerrole: 'Doct Dissert Advisor (AC)',
              position: 7
            },
            {
              name: 'Banner, Bruce',
              readerrole: 'Outside Dissert Co-Adv (AC)',
              position: 8
            },
            {
              name: 'Spector, Marc',
              readerrole: 'Outside Dissert Reader (AC)',
              position: 9
            },
            {
              name: 'Castle, Frank',
              readerrole: 'Doct Dissert Rdr (NonAC)',
              position: 10
            }
          ]
        )
      end

      let(:subfield_e_values) do
        [
          'degree supervisor.',
          'degree committee member.'
        ]
      end

      it 'has the correct number of expected readers' do
        expect(marc_record.fields('700').count).to eq(10)
      end

      it 'contains the expected structure for readers' do
        marc_record.each_by_tag('700') do |field|
          expect(field.subfields.map(&:code)).to contain_exactly('a', 'e', '4')
          expect(field.indicator1).to eq('1')
          expect(field.indicator2).to eq(' ')
          expect(field['a']).to end_with(',')
          expect(field['e']).to be_in(subfield_e_values)
          expect(field['4']).to eq('ths')
        end
      end

      it 'has the advisors (and co-advisors) first, alphabetized, then non-advisors, alphabetized' do
        advisor_names = marc_record.fields('700').filter_map { |field| field['a'] }
        expect(advisor_names).to eq([
                                      'Banner, Bruce,', # co-advisor
                                      'Boyd, Stephen,',
                                      'Marvel, Captain,', # co-advisor
                                      'Shoo, Mister,',
                                      'Stark, Tony,',
                                      # non-advisors
                                      'Castle, Frank,',
                                      'Leskovec, Jure,',
                                      'Spector, Marc,',
                                      'Weissman, Tsachy,',
                                      'Woman, Wonder,'
                                    ])
      end
    end

    describe '710 fields for school and department' do
      let(:fields710) { marc_record.fields('710') }

      context 'when school and department are present' do
        it 'adds a 710 for each' do
          expect(fields710.count).to eq(2)
          expect(fields710[0].indicator1).to eq('2')
          expect(fields710[0].indicator2).to eq(' ')
          expect(fields710[0]['a']).to eq('Stanford University.')
          expect(fields710[0]['b']).to eq('School of Engineering.')
          expect(fields710[0]['0']).to eq('http://id.loc.gov/authorities/names/n82220006')
          expect(fields710[0]['1']).to eq('https://ror.org/00f54p054')
          expect(fields710[1]['b']).to eq('Department of Electrical Engineering.')
          expect(fields710[1]['1']).to eq('https://ror.org/00f54p054')
        end
      end

      context 'when school only is present' do
        let(:department) { nil }
        let(:school) { 'Law School' }

        it 'adds a 710 for school only' do
          expect(fields710.count).to eq(1)
          expect(fields710[0]['b']).to eq('School of Law.')
        end
      end

      context 'when a school goes directly in subfield a' do
        let(:department) { nil }
        let(:school) { 'School of Earth,Energy,EnvSci' }

        it 'adds a 710 with school in subfield a' do
          expect(fields710.count).to eq(1)
          expect(fields710[0]['a']).to eq('Stanford School of Earth, Energy & Environmental Sciences.')
          expect(fields710[0]['0']).to match('^http://id.loc.gov/authorities/names/')
          expect(fields710[0]['1']).to eq('https://ror.org/00f54p054')
        end
      end

      context 'when school and department are present, but department is excluded' do
        let(:department) { 'Business' }
        let(:school) { 'Graduate School of Business' }

        it 'adds a 710 for school only' do
          expect(fields710.count).to eq(1)
          expect(fields710[0]['b']).to eq('Graduate School of Business.')
          expect(fields710[0]['1']).to eq('https://ror.org/00f54p054')
        end
      end
    end

    describe '856 field for purl' do
      let(:field856) { marc_record.fields('856').first }

      it 'has one 856 field' do
        expect(marc_record.fields('856').count).to eq(1)
        expect(field856.indicator1).to eq('4')
        expect(field856.indicator2).to eq('0')
      end

      it 'has the purl as subfield u' do
        expect(field856.subfields.map(&:code)).to contain_exactly('u')
        expect(field856['u']).to eq "#{Settings.purl_uri}/#{druid.split(':').last}"
      end
    end

    describe '910 field for ETD url' do
      let(:field910) { marc_record.fields('910').first }

      it 'has one 910 field' do
        expect(marc_record.fields('910').count).to eq(1)
        expect(field910.indicator1).to eq(' ')
        expect(field910.indicator2).to eq(' ')
      end

      it 'has the ETD url as subfield a' do
        expect(field910.subfields.map(&:code)).to contain_exactly('a')
        expect(field910['a']).to eq "https://etd.stanford.edu/view/#{submission.dissertation_id}"
      end
    end
  end

  describe '#format_full_name' do
    let(:full_name) { creator.send(:format_full_name, raw_name) }

    context 'when first last' do
      let(:raw_name) { 'Ludwig Wittgenstein' }

      it 'returns first last' do
        expect(full_name).to eq('Ludwig Wittgenstein')
      end
    end

    context 'when last, first' do
      let(:raw_name) { 'Wittgenstein, Ludwig' }

      it 'returns first last' do
        expect(full_name).to eq('Ludwig Wittgenstein')
      end
    end

    context 'when last suffix, first' do
      let(:raw_name) { 'Wittgenstein Jr., Ludwig' }

      it 'returns first last, suffix' do
        expect(full_name).to eq('Ludwig Wittgenstein, Jr.')
      end
    end
  end

  context 'with abstract too long for max allowed for single marc field' do
    let(:long_abstract) { File.read(file_fixture('long_abstract.txt')) }

    before do
      submission.update!(abstract: long_abstract)
    end

    describe '#create' do
      let(:marc_record) { creator.create }

      it 'has multiple 520 fields' do
        expect(marc_record.fields('520').count).to eq(2)
      end

      it 'combining the text of the multiple 520s is the same as the unsplit text' do
        combined = ''.dup
        marc_record.each_by_tag('520') do |field|
          combined << ' ' if combined.present?
          combined << field['a']
        end
        expect(creator.send(:format_aacr2, combined)).to eq creator.send(:format_aacr2, long_abstract)
      end
    end
  end
end
