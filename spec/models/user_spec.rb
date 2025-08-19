# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User do
  subject(:user) { described_class.new(remote_user:, **initialization_params) }

  let(:initialization_params) { {} }
  let(:remote_user) { 'etdsubmitter@stanford.edu' }

  describe '#sunetid' do
    it 'strips the username from the email address' do
      expect(user.sunetid).to eq('etdsubmitter')
    end
  end

  describe '#groups' do
    it 'returns an empty Groups instance by default' do
      expect(user.groups.to_s).to be_blank
    end

    context 'with groups added' do
      let(:initialization_params) { { groups: %w[students staff] } }

      it 'returns a populated Groups instance' do
        expect(user.groups.to_s).to eq('students, staff')
      end
    end
  end

  describe '#orcid' do
    it 'returns nil by default' do
      expect(user.orcid).to be_nil
    end

    context 'with orcid added' do
      let(:initialization_params) { { orcid: Settings.test_orcid } }

      it 'returns the supplied orcid' do
        expect(user.orcid).to eq(Settings.test_orcid)
      end
    end
  end

  describe '.from_request' do
    subject(:user) { described_class.from_request(request: instance_double(ActionDispatch::Request, env: fake_env)) }

    let(:fake_env) do
      {
        described_class::REMOTE_USER_HEADER => 'fakeuser@stanford.edu',
        described_class::USER_GROUPS_HEADER => 'students;staff',
        described_class::ORCID_ID_HEADER => '(null)'
      }
    end

    it 'splits groups by semi-colons' do
      expect(user.groups.to_s).to eq('students, staff')
    end

    it 'considers a special string to indicate no orcid value' do
      expect(user.orcid).to be_nil
    end

    context 'when missing groups and orcid' do
      let(:fake_env) do
        {
          described_class::REMOTE_USER_HEADER => 'fakeuser@stanford.edu'
        }
      end

      it 'parses no groups from the request' do
        expect(user.groups.to_s).to eq('')
      end

      it 'parses no orcid from the request' do
        expect(user.orcid).to be_nil
      end
    end
  end
end
