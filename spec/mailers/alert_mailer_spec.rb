# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AlertMailer do
  before do
    ActionMailer::Base.deliveries = []
    # Do not send honeybadger notifications in test suite!
    allow(Honeybadger).to receive(:notify)
  end

  let(:subject_prefix) { described_class.new.send(:subject_prefix) }

  describe '#ps_submit_exception' do
    it 'sends a properly formatted alert email for an exception' do
      mail = described_class.ps_submit_exception('0001', 'Some Exception Message').deliver_now
      expect(ActionMailer::Base.deliveries.size).to eq(1)
      expect(mail.encoded).to match(/Unable to submit the dissertation xml to PeopleSoft for: 0001/)
      expect(mail.encoded).to match(/Some Exception Message/)
      expect(mail.subject).to eq("#{subject_prefix} Error submitting ETD information to PeopleSoft")
      expect(mail.to).to eq(['fake-alert-list@example.com'])
    end
  end

  describe '#ps_incoming_dissertation_exception' do
    it 'sends a properly formatted alert email for incoming xml processing problems' do
      mail = described_class.ps_incoming_dissertation_exception('0002',
                                                                'Some Exception Message for incoming ETD').deliver_now
      expect(ActionMailer::Base.deliveries.size).to eq(1)
      expect(mail.encoded).to match(/Unable to process the incoming dissertation from Peoplesoft for: 0002/)
      expect(mail.encoded).to match(/Some Exception Message for incoming ETD/)
      expect(mail.subject).to eq("#{subject_prefix} Error processing incoming dissertation from Peoplesoft")
      expect(mail.to).to eq(['fake-alert-list@example.com'])
    end
  end

  describe '#corrupt_pdf_notification' do
    it 'sends a properly formatted alert email for corrupt pdf problems' do
      mail = described_class.corrupt_pdf_notification('0002', 'Some Exception Message for incoming ETD').deliver_now
      expect(ActionMailer::Base.deliveries.size).to eq(1)
      expect(mail.encoded).to match(/Unable to create augmented pdf for dissertation: 0002/)
      expect(mail.encoded).to match(/Some Exception Message/)
      expect(mail.subject).to eq("#{subject_prefix} Error creating augmented pdf")
      expect(mail.to).to eq(['fake-alert-list@example.com'])
    end
  end

  describe '#unable_to_create_workflow' do
    it 'sends a properly formatted alert email for problems with workflow creation' do
      mail = described_class.unable_to_create_workflow('0002').deliver_now
      expect(ActionMailer::Base.deliveries.size).to eq(1)
      expect(mail.encoded).to match(/Unable to create workflow for dissertation: 0002/)
      expect(mail.encoded)
        .to match(/NOTE: this workflow operation will be automatically retried and may not need intervention./)
      expect(mail.subject).to eq("#{subject_prefix} Error with Etd Submit workflow create")
    end
  end

  describe '#unable_to_update_workflow' do
    it 'sends a properly formatted alert email for problems with updating workflow' do
      mail = described_class.unable_to_update_workflow('0002').deliver_now
      expect(ActionMailer::Base.deliveries.size).to eq(1)
      expect(mail.encoded).to match(/Unable to update workflow for dissertation: 0002/)
      expect(mail.encoded)
        .to match(/NOTE: this workflow operation will be automatically retried and may not need intervention./)
      expect(mail.subject).to eq("#{subject_prefix} Error with Etd Submit workflow update")
      expect(mail.to).to eq(['fake-alert-list@example.com'])
    end
  end

  describe '#readers_missing' do
    it 'sends a properly formatted alert email when readers are missing' do
      mail = described_class.readers_missing('0002').deliver_now
      expect(ActionMailer::Base.deliveries.size).to eq(1)
      expect(mail.encoded).to match(/The incoming dissertation from Peoplesoft is missing readers: 0002/)
      expect(mail.subject).to eq("#{subject_prefix} Dissertation is missing readers")
      expect(mail.to).to eq(['fake-alert-list@example.com'])
    end
  end

  describe '#unable_to_build_marc' do
    let(:exception) { RuntimeError.new }

    before { allow(exception).to receive(:backtrace).and_return(%w[error1 error2]) }

    it 'sends a properly formatted alert email when marc cannot be built' do
      mail = described_class.unable_to_build_marc('filename.txt', 'some detail', exception).deliver_now
      expect(ActionMailer::Base.deliveries.size).to eq(1)
      expect(mail.encoded).to include("Problem trying to create MARC file 'filename.txt': some detail.")
      expect(mail.subject).to eq("#{subject_prefix} Failed to build MARC record")
      expect(mail.to).to eq(['fake-alert-list@example.com'])
    end
  end

  context 'when not in alertable enviromment' do
    around do |example|
      original_env = Settings.ps_env
      Settings.ps_env = 'not_used'
      example.run
      Settings.ps_env = original_env
    end

    describe '#ps_submit_exception' do
      it 'returns nil and sends no messages' do
        expect(
          described_class.ps_submit_exception('0001', 'some exception message').deliver_now
        ).to be_nil
        expect(ActionMailer::Base.deliveries.size).to eq(0)
        expect(Honeybadger).not_to have_received(:notify)
      end
    end
  end

  describe '#ready_for_cataloging' do
    let(:etd_title) { 'My Thesis' }
    let(:etd_url) { "#{Settings.catalog.folio.url}/inventory/view?qindex=hrid&amp;query=in2222" }

    before do
      allow(Settings).to receive_messages(catalog_record_id: 'folio',
                                          skip_cataloging_alert: [
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
      expect(mail.subject).to eq("#{subject_prefix} ETDs ready to be cataloged")
      expect(mail.to).to eq(['fake-report-list@example.com'])
    end
  end

  context 'when no ETDs ready for cataloging' do
    describe '#ready_for_cataloging' do
      before do
        allow(Settings).to receive_messages(catalog_record_id: 'folio',
                                            skip_cataloging_alert: [
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
      end
    end
  end
end
