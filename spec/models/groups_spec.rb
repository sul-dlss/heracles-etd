# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Groups do
  subject(:groups) { described_class.new(groups: groups_list) }

  let(:groups_list) { [] }

  describe '#dlss?' do
    it 'returns false' do
      expect(groups).not_to be_dlss
    end

    context 'when DLSS group is included' do
      let(:groups_list) { [Settings.groups.dlss] }

      it 'returns true' do
        expect(groups).to be_dlss
      end
    end
  end

  describe '#registrar?' do
    it 'returns false' do
      expect(groups).not_to be_registrar
    end

    context 'when Registrar group is included' do
      let(:groups_list) { [Settings.groups.registrar] }

      it 'returns true' do
        expect(groups).to be_registrar
      end
    end
  end

  describe '#reports?' do
    it 'returns false' do
      expect(groups).not_to be_reports
    end

    context 'when Reports group is included' do
      let(:groups_list) { [Settings.groups.reports] }

      it 'returns true' do
        expect(groups).to be_reports
      end
    end
  end

  describe '#to_s' do
    let(:groups_list) { [Settings.groups.reports, Settings.groups.dlss, Settings.groups.registrar] }

    it 'joins the groups with a comma & a space' do
      expect(groups.to_s).to eq('sdr:etds-quarterly-reports, sdr:etds-sul-staff, sdr:etds-registrar-staff')
    end
  end
end
