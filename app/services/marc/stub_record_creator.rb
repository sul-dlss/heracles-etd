# frozen_string_literal: true

module Marc
  # Service for creating a stub MARC record for an ETD
  class StubRecordCreator # rubocop:disable Metrics/ClassLength
    include ActionView::Helpers::TextHelper # for word_wrap for long abstracts

    def self.create(druid:)
      new(druid:).create
    end

    def initialize(druid:)
      @bare_druid = druid.split('druid:').last
      @etd = Submission.find_by!(druid:)
    end

    def create # rubocop:disable Metrics/AbcSize
      marc = initialize_marc

      add_author_title_and_orcid(marc)
      add_publication_and_copyright_years(marc)
      add_3xx_fields(marc)
      add_submitted_to(marc)
      add_thesis_field(marc)
      add_abstract(marc)
      add_advisors_and_readers(marc)
      add_school_and_department(marc)

      marc.append(MARC::DataField.new('856', '4', '0', ['u', "#{Settings.purl.url}/#{bare_druid}"]))
      marc.append(MARC::DataField.new('910', ' ', ' ', ['a', "https://etd.stanford.edu/view/#{etd.dissertation_id.strip}"]))

      marc
    end

    private

    attr_reader :bare_druid, :etd

    School = Struct.new(:name, :uri)
    private_constant :School

    SCHOOL_MAP = {
      'Humanities & Sciences' => School.new('School of Humanities and Sciences', 'http://id.loc.gov/authorities/names/no2009155385'),
      'Doerr School of Sustainability' => School.new('Stanford Doerr School of Sustainability', 'http://id.loc.gov/authorities/names/no2023010264'),
      'Graduate School of Business' => School.new('Graduate School of Business', ' http://id.loc.gov/authorities/names/n81052656'),
      'School of Engineering' => School.new('School of Engineering', 'http://id.loc.gov/authorities/names/n82220006'),
      'School of Medicine' => School.new('School of Medicine', 'http://id.loc.gov/authorities/names/n79091625'),
      'Graduate School of Education' => School.new('Graduate School of Education', 'http://id.loc.gov/authorities/names/no2016136517'),
      'School of Earth,Energy,EnvSci' => School.new('Stanford School of Earth, Energy & Environmental Sciences', 'http://id.loc.gov/authorities/names/no2015018855'),
      'Law School' => School.new('School of Law', 'http://id.loc.gov/authorities/names/n81144217')
    }.freeze
    private_constant :SCHOOL_MAP

    # Create skeleton MARC record - fixed fields and 040
    def initialize_marc # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      marc = MARC::Record.new

      # Populate the MARC leader
      marc.leader[5] = 'n'
      marc.leader[6] = 'a'
      marc.leader[7] = 'm'
      marc.leader[9] = 'a'
      marc.leader[17] = '3'
      marc.leader[18] = 'i'

      # Add control fields
      marc.append(MARC::ControlField.new('001', "dor#{bare_druid}"))
      marc.append(MARC::ControlField.new('006', 'm     o  d        '))
      marc.append(MARC::ControlField.new('007', 'cr un'))
      cf008 = "#{Time.zone.now.strftime('%y%m%d')}t#{publication_year}#{copyright_year}cau     om    000 0 eng d"
      marc.append(MARC::ControlField.new('008', cf008))

      marc.append(
        MARC::DataField.new('024', '7', ' ', ['a', "#{Settings.datacite.prefix}/#{bare_druid}"], %w[2 doi])
      )

      # Begin building data fields
      marc.append(MARC::DataField.new('040', ' ', ' ', %w[a CSt], %w[b eng], %w[e rda], %w[c CSt]))

      marc
    end

    # Add the 100 and 245 fields to the MARC record
    def add_author_title_and_orcid(marc) # rubocop:disable Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity, Metrics/AbcSize, Metrics/MethodLength
      raw_name = etd.name
      name_suffix = etd.suffix.dup || '' # string munging is done to the duplicate value, not the value in the database
      name_prefix = etd.prefix.dup || ''
      author_field = MARC::DataField.new('100', '1', ' ', ['a', "#{raw_name},"])
      author_field.append(MARC::Subfield.new('c', "#{name_suffix},")) if name_suffix.present?
      author_field.append(MARC::Subfield.new('c', "#{name_prefix},")) if name_prefix.present?
      author_field.append(MARC::Subfield.new('e', 'author.'))
      author_field.append(MARC::Subfield.new('1', etd.orcid)) if etd.orcid.present?

      marc.append(author_field)

      # Add name (as first last) to 245 MARC field
      full_name = format_full_name(raw_name)
      if !name_suffix.nil? && name_suffix.strip != ''
        name_suffix.chop! unless name_suffix.match(/\.$/).nil?
        full_name << ', ' << name_suffix
      end
      full_name = "#{name_prefix} #{full_name}" if !name_prefix.nil? && name_prefix.strip != ''
      marc.append(MARC::DataField.new('245', '1', '0', ['a', "#{filter_text_dup(etd.title)} /"],
                                      ['c', format_aacr2(full_name)]))
    end

    def add_publication_and_copyright_years(marc)
      marc.append(MARC::DataField.new('264', ' ', '1',
                                      ['a', '[Stanford, California] :'],
                                      ['b', '[Stanford University],'],
                                      ['c', formatted_degreeconf_year]))
      marc.append(MARC::DataField.new('264', ' ', '4', ['c', "©#{copyright_year}"]))
    end

    def add_3xx_fields(marc)
      marc.append(MARC::DataField.new('300', ' ', ' ', ['a', '1 online resource.']))
      marc.append(MARC::DataField.new('336', ' ', ' ', %w[a text], %w[b txt], %w[2 rdacontent]))
      marc.append(MARC::DataField.new('337', ' ', ' ', %w[a computer], %w[b c], %w[2 rdamedia]))
      marc.append(MARC::DataField.new('338', ' ', ' ', ['a', 'online resource'], %w[b cr], %w[2 rdacarrier]))
    end

    def add_submitted_to(marc)
      department = etd.department
      return if department.nil?

      if /Business|Education|Law/.match?(department)
        marc.append(MARC::DataField.new('500', ' ', ' ',
                                        ['a', "Submitted to the School of #{format_aacr2(department)}"]))
      else
        marc.append(MARC::DataField.new('500', ' ', ' ',
                                        ['a', "Submitted to the Department of #{format_aacr2(department)}"]))
      end
    end

    def add_thesis_field(marc)
      marc.append(MARC::DataField.new('502', ' ', ' ',
                                      %w[g Thesis],
                                      ['b', etd.degree.strip.to_s],
                                      ['c', 'Stanford University'],
                                      ['d', formatted_degreeconf_year]))
    end

    # Abstracts are sometimes too long for the maximum length for a single MARC field,
    #   which is 9999 (4 bytes are allocated in MARC for the field length)
    #   With the field tags, indicators, subfield tags, etc we need to be a bit more conservative.
    #   Note that 9950 was too big in the case of one abstract
    def add_abstract(marc)
      formatted_abstract = format_aacr2(etd.abstract)
      # Dollar signs need to be escaped per Folio documentation or
      # they are misinterpreted as subfield delimiters.
      formatted_abstract.gsub!('$', '{dollar}')
      if formatted_abstract.length <= 9925
        marc.append(MARC::DataField.new('520', '3', ' ', ['a', formatted_abstract]))
      else
        break_seq = '@@##@@'
        with_breaks = word_wrap(formatted_abstract, line_width: 9925, break_sequence: break_seq)
        with_breaks.split(break_seq).each do |section|
          marc.append(MARC::DataField.new('520', '3', ' ', ['a', section]))
        end
      end
    end

    def add_advisors_and_readers(marc) # rubocop:disable Metrics/AbcSize
      # advisors first in alphabetical order
      etd.readers.advisors.pluck(:name).sort.each do |advisor|
        marc.append(MARC::DataField.new('700', '1', ' ', ['a', "#{advisor.strip},"], ['e', 'degree supervisor.'],
                                        %w[4 ths]))
      end

      # then non-advisors in alphabetical order
      etd.readers.non_advisors.pluck(:name).sort.each do |reader|
        marc.append(MARC::DataField.new('700', '1', ' ', ['a', "#{reader.strip},"], ['e', 'degree committee member.'],
                                        %w[4 ths]))
      end
    end

    STANFORD_ROR_URI = 'https://ror.org/00f54p054'
    private_constant :STANFORD_ROR_URI

    def add_school_and_department(marc) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      schoolname = etd.schoolname
      school = SCHOOL_MAP.fetch(schoolname)
      school_contributor = if ['Doerr School of Sustainability', 'School of Earth,Energy,EnvSci'].include?(schoolname)
                             MARC::DataField.new('710', '2', ' ', ['a', format_aacr2(school.name)], ['0', school.uri])
                           else
                             MARC::DataField.new('710', '2', ' ', ['a', 'Stanford University.'],
                                                 ['b', format_aacr2(school.name)], ['0', school.uri])
                           end
      school_contributor.append(MARC::Subfield.new('1', STANFORD_ROR_URI))
      marc.append(school_contributor)

      department = etd.department
      return if department.blank? || department.match?(/Business|Education|Law/)

      department_contributor = MARC::DataField.new('710', '2', ' ', ['a', 'Stanford University.'],
                                                   ['b', "Department of #{format_aacr2(department)}"])
      department_contributor.append(MARC::Subfield.new('1', STANFORD_ROR_URI))
      marc.append(department_contributor)
    end

    def formatted_degreeconf_year
      @formatted_degreeconf_year ||= format_aacr2(etd.degreeconfyr).to_s
    end

    # Use submitted_at for copyright year, if available, else use degreeconfyr
    def copyright_year
      @copyright_year ||=
        if etd.submitted?
          etd.submitted_at.year.to_s
        else
          etd.degreeconfyr
        end
    end

    # Use current year as publication year always
    def publication_year
      @publication_year ||= Time.zone.now.year.to_s
    end

    # This returns "first, last" and does some meager parsing for suffixes and corrects for them when found.
    def format_full_name(raw_name)
      return raw_name unless raw_name.include?(',')

      full_name = raw_name.dup
      generational_suffix = full_name.slice!(/Jr\.|Sr\.|II|III|IV/)

      full_name =~ /([^,\r\n]*),\s*(.*)/
      last = Regexp.last_match(1)
      first = Regexp.last_match(2)
      full_name = [first.strip, last.strip].join(' ').sub(',', '')
      return full_name if generational_suffix.nil?

      "#{full_name}, #{generational_suffix.strip}"
    end

    # Filter out smart text and em dashes from a duplicate of the String passed in
    def filter_text_dup(text)
      filtered_text = text.dup # don't change the original in database
      filtered_text.strip!
      filtered_text.gsub!(/\342\200\234|\342\200\235/, '"')
      filtered_text.gsub!(/\342\200\230|\342\200\231/, "'")
      filtered_text.gsub!(/\342\200\223/, '--')
      filtered_text.gsub!(/\342\200\246/, '...')
      filtered_text.gsub!(/\r|\n|\t/, ' ')
      filtered_text
    end

    # Make sure that the returned string has no leading/trailing whitespace and ends with a period
    #  the returned string is a duplicate of the String passed in
    def format_aacr2(text)
      filtered_text = filter_text_dup(text)
      filtered_text << '.' unless filtered_text.end_with?('.')
      filtered_text
    end
  end
end
