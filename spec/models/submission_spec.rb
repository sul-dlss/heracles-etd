# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Submission do
  subject(:submission) { build(:submission, :with_dissertation_file, :with_supplemental_files, :with_permission_file) }

  describe '#first_name' do
    it 'returns the first name from the name field' do
      expect(submission.first_name).to eq('Jane')
    end
  end

  describe '#dissertation_file' do
    it 'is attached' do
      expect(submission.dissertation_file).to be_attached
      expect(submission.dissertation_file.filename).to eq('dissertation.pdf')
      expect(submission.dissertation_file.content_type).to eq('application/pdf')
    end
  end

  describe '#supplemental_files' do
    it 'are attached' do
      expect(submission.supplemental_files.count).to eq(2)
      expect(submission.supplemental_files.first.filename).to eq('supplemental_1.pdf')
      expect(submission.supplemental_files.second.filename).to eq('supplemental_2.pdf')
    end
  end

  describe '#permission_files' do
    it 'is attached' do
      expect(submission.permission_files).to be_attached
      expect(submission.permission_files.first.filename).to eq('permission.pdf')
    end
  end
end
