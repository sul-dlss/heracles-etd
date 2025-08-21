# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Cocina::DroAccessGenerator do
  describe '.create' do
    subject(:result_hash) { described_class.create(submission:) }

    let(:druid) { 'druid:oo000oo0000' }
    let(:submission) { build(:submission, :submitted, :reader_approved, druid:) }

    # NOTE: stanford vs world access is based on the embargo date and on "external_visibility."

    context 'when embargo is immediately' do
      before do
        submission.embargo = 'immediately'
        submission.save
      end

      # visibility used to be set to 20 or 100 percent, but this stopped being used
      # visibility is nil for all newly created ETDs, which is treated as 100 percent
      context 'when external_visibility is nil' do
        # it is nil by default (and because it's not set in our factory)

        it 'has world access rights' do
          expect(result_hash[:view]).to eq('world')
          expect(result_hash[:download]).to eq('world')
        end

        it 'has no embargo key in hash' do
          expect(result_hash).not_to include(:embargo)
        end

        it 'is valid cocina DROAccess' do
          expect { Cocina::Models::DROAccess.new(result_hash) }.not_to raise_error
        end
      end

      # this is a "just in case" test for old data
      context 'when external_visibility is 100' do
        before do
          submission.external_visibility = '100'
          submission.save
        end

        it 'has world access rights' do
          expect(result_hash[:view]).to eq('world')
          expect(result_hash[:download]).to eq('world')
        end

        it 'has no embargo key in hash' do
          expect(result_hash).not_to include(:embargo)
        end

        it 'is valid cocina DROAccess' do
          expect { Cocina::Models::DROAccess.new(result_hash) }.not_to raise_error
        end
      end

      # this is a "just in case" test for old data
      context 'when external_visibility is 20' do
        before do
          submission.external_visibility = '20'
          submission.save
        end

        it 'has stanford access rights' do
          expect(result_hash[:view]).to eq('stanford')
          expect(result_hash[:download]).to eq('stanford')
        end

        it 'has no embargo key in hash' do
          expect(result_hash).not_to include(:embargo)
        end

        it 'is valid cocina DROAccess' do
          expect { Cocina::Models::DROAccess.new(result_hash) }.not_to raise_error
        end
      end
    end

    context 'when embargo is nil' do
      # it is nil by default (and because it's not set in our factory)

      # visibility used to be set to 20 or 100 percent, but this stopped being used
      # visibility is nil for all newly created ETDs, which is treated as 100 percent
      context 'when external_visibility is nil' do
        # it is nil by default (and because it's not set in our factory)
        before do
          submission.save
        end

        it 'has world access rights' do
          expect(result_hash[:view]).to eq('world')
          expect(result_hash[:download]).to eq('world')
        end

        it 'has no embargo key in hash' do
          expect(result_hash).not_to include(:embargo)
        end

        it 'is valid cocina DROAccess' do
          expect { Cocina::Models::DROAccess.new(result_hash) }.not_to raise_error
        end
      end

      # this is a "just in case" test for old data
      context 'when external_visibility is 100' do
        before do
          submission.external_visibility = '100'
          submission.save
        end

        it 'has world access rights' do
          expect(result_hash[:view]).to eq('world')
          expect(result_hash[:download]).to eq('world')
        end

        it 'has no embargo key in hash' do
          expect(result_hash).not_to include(:embargo)
        end

        it 'is valid cocina DROAccess' do
          expect { Cocina::Models::DROAccess.new(result_hash) }.not_to raise_error
        end
      end

      # this is a "just in case" test for old data
      context 'when external_visibility is 20' do
        before do
          submission.external_visibility = '20'
          submission.save
        end

        it 'has stanford access rights' do
          expect(result_hash[:view]).to eq('stanford')
          expect(result_hash[:download]).to eq('stanford')
        end

        it 'has no embargo key in hash' do
          expect(result_hash).not_to include(:embargo)
        end

        it 'is valid cocina DROAccess' do
          expect { Cocina::Models::DROAccess.new(result_hash) }.not_to raise_error
        end
      end
    end

    context 'when embargo is not immediate' do
      before do
        submission.embargo = '6 months'
        submission.submitted_at = Time.zone.now
        submission.save
      end

      # visibility used to be set to 20 or 100 percent, but this stopped being used
      # visibility is nil for all newly created ETDs, which is treated as 100 percent
      context 'when external_visibility is nil' do
        # it is nil by default (and because it's not set in our factory)

        it 'has stanford access rights' do
          expect(result_hash[:view]).to eq('stanford')
          expect(result_hash[:download]).to eq('stanford')
        end

        it 'populates embargo in hash' do
          expect(result_hash[:embargo][:view]).to eq('world')
          expect(result_hash[:embargo][:download]).to eq('world')
          expect(result_hash[:embargo][:releaseDate]).to eq(submission.embargo_release_date.iso8601)
        end

        it 'is valid cocina DROAccess' do
          expect { Cocina::Models::DROAccess.new(result_hash) }.not_to raise_error
        end
      end

      # this is a "just in case" test for old data
      context 'when external_visibility is 100' do
        before do
          submission.external_visibility = '100'
          submission.save
        end

        it 'has stanford access rights' do
          expect(result_hash[:view]).to eq('stanford')
          expect(result_hash[:download]).to eq('stanford')
        end

        it 'populates embargo in hash' do
          expect(result_hash[:embargo][:view]).to eq('world')
          expect(result_hash[:embargo][:download]).to eq('world')
          expect(result_hash[:embargo][:releaseDate]).to eq(submission.embargo_release_date.iso8601)
        end

        it 'is valid cocina DROAccess' do
          expect { Cocina::Models::DROAccess.new(result_hash) }.not_to raise_error
        end
      end

      # this is a "just in case" test for old data
      context 'when external_visibility is 20' do
        before do
          submission.external_visibility = '20'
          submission.save
        end

        it 'has stanford access rights' do
          expect(result_hash[:view]).to eq('stanford')
          expect(result_hash[:download]).to eq('stanford')
        end

        it 'populates embargo in hash' do
          expect(result_hash[:embargo][:view]).to eq('world')
          expect(result_hash[:embargo][:download]).to eq('world')
          expect(result_hash[:embargo][:releaseDate]).to eq(submission.embargo_release_date.iso8601)
        end

        it 'is valid cocina DROAccess' do
          expect { Cocina::Models::DROAccess.new(result_hash) }.not_to raise_error
        end
      end
    end

    describe 'license' do
      context 'when a license is selected' do
        before do
          submission.cclicense = '3'
          submission.save
        end

        it 'is the url for the selected license' do
          expect(result_hash[:license]).to eq('https://creativecommons.org/licenses/by-nd/3.0/legalcode')
        end
      end

      context 'when license is none' do
        before do
          submission.cclicense = nil
          submission.save
        end

        it 'maps to nil' do
          expect(result_hash[:license]).to be_nil
        end
      end
    end

    describe 'copyright statement' do
      before do
        submission.submitted_at = Time.zone.parse('2020-03-15')
        submission.name = 'Nineteen, Omicron Covid'
        submission.save
      end

      it 'has correct year and name' do
        expect(result_hash[:copyright]).to eq('(c) Copyright 2020 by Omicron Covid Nineteen')
      end
    end
  end
end
