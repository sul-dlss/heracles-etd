# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Routes', type: :routing do
  # These routes are referenced by external applications, so testing to make sure they are correctly resolved.
  it 'routes submission show' do
    expect(get('/submit/8548084437')).to route_to('submissions#show', id: '8548084437')
  end

  it 'routes submission edit' do
    expect(get('/submit/8548084437/edit')).to route_to('submissions#edit', id: '8548084437')
  end

  it 'routes reader review' do
    expect(get('/view/8548084437')).to route_to('submissions#reader_review', id: '8548084437')
  end
end
