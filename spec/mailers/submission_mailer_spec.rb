# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SubmissionMailer do
  before do
    ActionMailer::Base.deliveries = []
    # Do not send honeybadger notifications in test suite!
    allow(Honeybadger).to receive(:notify)
    allow(Honeybadger).to receive(:check_in)
  end

  describe '#ready_for_cataloging' do
    let(:etd_title) { 'My Thesis' }
    let(:etd_url) { "#{Settings.catalog.folio.url}/inventory/view?qindex=hrid&amp;query=in2222" }

    before do
      allow(Settings).to receive_messages(skip_cataloging_alert: [
                                            'druid:gh926rx4162', 'druid:wz924gg6479'
                                          ])
      create(:submission, :cataloged_in_ils, folio_instance_hrid: 'in1111')
      create(:submission, :submitted, :reader_approved, :registrar_approved, :loaded_in_ils,
             ils_record_created_at: 1.hour.ago, folio_instance_hrid: 'in2222')
      create(:submission, :submitted, :reader_approved, :registrar_approved, :loaded_in_ils,
             ils_record_created_at: 2.days.ago, folio_instance_hrid: 'in3333')
      create(:submission, :submitted, :reader_approved, :registrar_approved, :loaded_in_ils,
             ils_record_created_at: 2.days.ago, folio_instance_hrid: 'in4444',
             druid: 'druid:gh926rx4162')
    end

    it 'lists the correct ETDs' do
      mail = described_class.ready_for_cataloging
      expect(mail.encoded).not_to match(/in1111/)
      expect(mail.encoded).to match(/in2222/)
      expect(mail.encoded).to match(/in3333/)
      expect(mail.encoded).not_to match(/in4444/)
      expect(mail.encoded).to include("<a href=\"#{etd_url}\">#{etd_title}")
      expect(mail.subject).to eq('[TEST] ETDs ready to be cataloged')
      expect(mail.to).to eq(['fake-report-list@example.com'])
      expect(Honeybadger).to have_received(:check_in).with(Settings.honeybadger_checkins.ready_for_cataloging)
    end
  end

  context 'when no ETDs ready for cataloging' do
    describe '#ready_for_cataloging' do
      before do
        allow(Settings).to receive_messages(skip_cataloging_alert: [
                                              'druid:gh926rx4162', 'druid:wz924gg6479'
                                            ])
        create(:submission, :submitted, :reader_approved, :registrar_approved, :loaded_in_ils, :cataloged_in_ils,
               ils_record_created_at: 1.hour.ago, folio_instance_hrid: 'in1111')
        create(:submission, :submitted, :reader_approved, :registrar_approved, :loaded_in_ils, :cataloged_in_ils,
               ils_record_created_at: 2.days.ago, folio_instance_hrid: 'in2222')
      end

      it 'does not send the email' do
        mail = described_class.ready_for_cataloging
        expect(mail.encoded).to be_nil
        expect(Honeybadger).to have_received(:check_in).with(Settings.honeybadger_checkins.ready_for_cataloging)
      end
    end
  end
end
