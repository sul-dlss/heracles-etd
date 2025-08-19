# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Reader do
  subject(:reader) { build(:reader) }

  describe '#valid?' do
    it { is_expected.to be_valid }

    context 'when name is nil' do
      subject(:reader) { build(:reader, name: nil) }

      it { is_expected.not_to be_valid }
    end

    context 'when name is empty string' do
      subject(:reader) { build(:reader, name: '') }

      it { is_expected.not_to be_valid }
    end

    context 'when name is whitespace' do
      subject(:reader) { build(:reader, name: ' ') }

      it { is_expected.not_to be_valid }
    end

    context 'when position is nil' do
      subject(:reader) { build(:reader, position: nil) }

      it { is_expected.not_to be_valid }
    end

    context 'when position is empty string' do
      subject(:reader) { build(:reader, position: '') }

      it { is_expected.not_to be_valid }
    end
  end

  describe '#signature_page_role' do
    # Default reader role in factory is not an advisory role
    it 'returns nil' do
      expect(reader.signature_page_role).to be_nil
    end

    context 'when reader has one of the primary advisor roles' do
      subject(:reader) { build(:reader, readerrole: 'Doct Dissert Advisor (AC)') }

      it 'returns Primary Adviser' do
        expect(reader.signature_page_role).to eq('Primary Adviser')
      end
    end

    context 'when reader has one of the co-advisor roles' do
      subject(:reader) { build(:reader, readerrole: 'Dissertation Co-Advisor') }

      it 'returns Co-Adviser' do
        expect(reader.signature_page_role).to eq('Co-Adviser')
      end
    end
  end

  describe '.advisors' do
    before do
      create_list(:reader, 3)
      create_list(:reader, 2, readerrole: 'Advisor')
      create_list(:reader, 2, readerrole: 'Co-Adv')
    end

    it 'returns expected number of advisor readers' do
      expect(described_class.advisors.count).to eq(4)
    end
  end
end
