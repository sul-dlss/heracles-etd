# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CreativeCommonsLicense do
  describe '#all' do
    let(:licenses) { described_class.all }

    it 'returns all Creative Commons licenses' do
      expect(licenses.length).to eq(7)
      license = licenses.last
      expect(license.id).to eq('6')
      expect(license.name).to eq('CC Attribution Non-Commercial No Derivatives license')
      expect(license.url).to eq('https://creativecommons.org/licenses/by-nc-nd/3.0/legalcode')
      expect(license.code).to eq('by-nc-nd')
      expect(license.signature_text).to eq('Noncommercial-No Derivative Works 3.0 United States License')
    end
  end

  describe '#find' do
    let(:license) { described_class.find('6') }

    it 'returns the correct Creative Commons license' do
      expect(license).to be_a(described_class)
      expect(license.name).to eq('CC Attribution Non-Commercial No Derivatives license')
    end
  end

  describe '#cc_license?' do
    it 'returns true for a Creative Commons license' do
      expect(described_class.find('6').cc_license?).to be true
    end

    it 'returns false when not a Creative Commons license' do
      expect(described_class.find('0').cc_license?).to be false
    end
  end

  describe '#image_path' do
    it 'returns the image path' do
      expect(described_class.find('6').image_path.to_s).to end_with('app/assets/images/cc_by_nc_nd.png')
    end
  end
end
