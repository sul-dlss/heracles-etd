# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Submission do
  subject(:submission) { build(:submission) }

  describe '#first_name' do
    it 'returns the first name from the name field' do
      expect(submission.first_name).to eq('Jane')
    end
  end
end
