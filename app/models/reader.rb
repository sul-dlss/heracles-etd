# frozen_string_literal: true

# Model for readers associated with submissions
class Reader < ApplicationRecord
  include PersonNameConcern

  self.inheritance_column = nil # allows us to use 'type' for something else, i.e. ["int"ernal | "ext"ernal]

  ADVISOR_ROLES =
    [
      # Primary advisor roles
      'Advisor',
      'Doct Dissert Advisor (AC)',
      'Outside Dissert Advisor (AC)',
      # Co-advisor roles
      'Co-Adv',
      'Dissertation Co-Advisor',
      'Doct Dissert Co-Adv (AC)',
      'Doct Dissert Co-Adv (NonAC)',
      'Outside Dissert Co-Adv (AC)'
    ].freeze

  belongs_to :submission
  validates :name, presence: true
  validates :position, presence: true

  scope :advisors, -> { where(readerrole: ADVISOR_ROLES) }
end
