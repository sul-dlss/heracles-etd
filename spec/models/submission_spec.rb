# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Submission do
  subject(:submission) { build(:submission) }

  describe '#first_name' do
    it 'returns the first name from the name field' do
      expect(submission.first_name).to eq('Jane')
    end
  end

  describe '#first_last_name' do
    it 'returns the first name followed by the last name from the name field' do
      expect(submission.first_last_name).to eq('Jane Doe')
    end
  end
end
