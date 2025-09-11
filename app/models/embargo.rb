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
    embargo_months = find(id).duration.in_months

    # Convert the approved timestamp to a date before advancing six months,
    # then back to a timestamp, which the embargo service requires.
    #
    # Why, you ask?
    #
    # Because there is a one-hour window every day in the late afternoon,
    # except between March & May (DST dates change from year to year), when
    # advancing a timestamp by six months causes perhaps unexpected behavior
    # due to the underlying timestamp varying between standard time and
    # daylight saving time. See below:
    #
    # > dt = Time.now + 6.months + 8.hours   # Start with a time in a problematic window
    # => 2021-02-18 16:57:47.654582794 -0800 # Note it's in PST
    # > dt2 = dt.months_since(6)             # Advance it by six months
    # => 2021-08-18 16:57:47.654582794 -0700 # Note it's in PDT
    # > dt.utc                               # If timestamps are compared in UTC...
    # => 2021-02-19 00:57:47.654582794 UTC   # then the day of the month changes!
    # > dt2.utc                              # and compared with another UTC date
    # => 2021-08-18 23:57:47.654582794 UTC   # an extra day is added to the embargo
    #
    # See also: https://medium.com/@dvandersluis/an-rspec-time-issue-and-its-not-about-timezones-a89bbd167b86
    start_date
      .to_date                      # convert to date
      .months_since(embargo_months) # THEN advance
      .beginning_of_day             # then convert back to time
  end
end
