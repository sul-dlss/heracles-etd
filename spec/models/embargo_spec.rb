# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Embargo do
  describe '.all' do
    let(:embargoes) { described_class.all }

    it 'returns all embargoes' do
      expect(embargoes.length).to eq(4)
      embargo = embargoes.last
      expect(embargo.id).to eq('2 years')
      expect(embargo.duration).to eq(2.years)
    end
  end

  describe '.find' do
    let(:embargo) { described_class.find('2 years') }

    it 'returns the correct embargo' do
      expect(embargo).to be_a(described_class)
      expect(embargo.duration).to eq(2.years)
    end
  end

  describe '.embargo_date' do
    let(:embargo_date) { described_class.embargo_date(start_date:, id: '2 years') }
    let(:start_date) { Time.zone.today.beginning_of_day }
    let(:expected_embargo_date) { (start_date + 2.years).to_time }

    it 'returns the correct embargo date' do
      expect(embargo_date).to eq(expected_embargo_date)
    end
  end
end
