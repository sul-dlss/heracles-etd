# frozen_string_literal: true

# Fixtures used in request specs
module RequestFixtures
  def registrar_xml(dissertation_id: '000123', title: 'My etd', regapproval: 'Not Approved', # rubocop:disable Metrics/ParameterLists
                    regcomment: nil, regactiondttm: nil, readerapproval: nil, readercomment: nil,
                    readeractiondttm: nil)
    <<~XML
      <DISSERTATION>
        <dissertationid>#{dissertation_id}</dissertationid>
        <title>#{title}</title>
        <type>Dissertation</type>
        <sunetid>student1</sunetid>
        <vpname>Provost McProvostpants</vpname>
        <degreeconfyr>2025</degreeconfyr>
        <schoolname>Graduate School of Education</schoolname>
        <readerapproval>#{readerapproval}</readerapproval>
        <readercomment>#{readercomment}</readercomment>
        <readeractiondttm>#{readeractiondttm}</readeractiondttm>
        <regapproval>#{regapproval}</regapproval>
        <regcomment>#{regcomment}</regcomment>
        <regactiondttm>#{regactiondttm}</regactiondttm>
        <documentaccess>No</documentaccess>
        <univid>12345678</univid>
        <prefix></prefix>
        <name>Student, I. M.</name>
        <suffix></suffix>
        <career code="GR">Graduate</career>
        <program code="EDUC">Education</program>
        <plan code="ED-PHD">Education</plan>
        <degree>PHD</degree>
        <term>1258</term>
        <sub deadline="2025-09-03"/>
        <subplan code="EDCTEPHD5">Science, Engineering &amp; Tech Ed</subplan>
        <reader>
          <sunetid>READ1</sunetid>
          <prefix>Mr.</prefix>
          <name>Reader,First</name>
          <suffix>Jr.</suffix>
          <type>int</type>
          <univid>987654321</univid>
          <readerrole>Doct Dissert Advisor (AC)</readerrole>
          <finalreader>Yes</finalreader>
        </reader>
        <reader>
          <sunetid> </sunetid>
          <prefix>Dr</prefix>
          <name>Reader,Second</name>
          <suffix> </suffix>
          <type>ext</type>
          <univid> </univid>
          <readerrole>Outside Reader</readerrole>
          <finalreader>No</finalreader>
        </reader>
      </DISSERTATION>
    XML
  end

  RSpec.configure do |config|
    config.include RequestFixtures, type: :request
  end
end
