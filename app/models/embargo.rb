# frozen_string_literal: true

# An active model for embargos.
class Embargo
  include ActiveModel::Model

  attr_accessor :id, :duration

  def self.all
    [
      new(id: 'immediately', duration: 0.months),
      new(id: '6 months', duration: 6.months),
      new(id: '1 year', duration: 1.year),
      new(id: '2 years', duration: 2.years)
    ]
  end

  def self.find(id)
    all.find { |embargo| embargo.id == id }
  end

  def self.embargo_date(start_date:, id:)
    start_date + find(id).duration
  end
end
