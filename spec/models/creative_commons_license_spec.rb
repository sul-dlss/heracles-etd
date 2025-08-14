# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CreativeCommonsLicense do
  describe '.all' do
    let(:licenses) { described_class.all }

    it 'returns all Creative Commons licenses' do
      expect(licenses.length).to eq(7)
      license = licenses.last
      expect(license.id).to eq('6')
      expect(license.name).to eq('CC Attribution Non-Commercial No Derivatives license')
      expect(license.url).to eq('https://creativecommons.org/licenses/by-nc-nd/3.0/legalcode')
      expect(license.code).to eq('by-nc-nd')
    end
  end

  describe '.find' do
    let(:license) { described_class.find('6') }

    it 'returns the correct Creative Commons license' do
      expect(license).to be_a(described_class)
      expect(license.name).to eq('CC Attribution Non-Commercial No Derivatives license')
    end
  end
end
