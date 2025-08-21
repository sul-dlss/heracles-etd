# frozen_string_literal: true

# Model for readers associated with submissions
class Reader < ApplicationRecord
  include PersonNameConcern
  include ReaderAdminConcern

  self.inheritance_column = nil # allows us to use 'type' for something else, i.e. ["int"ernal | "ext"ernal]

  PRIMARY_ADVISOR_ROLES = [
    'Advisor',
    'Doct Dissert Advisor (AC)',
    'Outside Dissert Advisor (AC)'
  ].freeze

  COADVISOR_ROLES = [
    'Co-Adv',
    'Dissertation Co-Advisor',
    'Doct Dissert Co-Adv (AC)',
    'Doct Dissert Co-Adv (NonAC)',
    'Outside Dissert Co-Adv (AC)'
  ].freeze

  ADVISOR_ROLES = (PRIMARY_ADVISOR_ROLES + COADVISOR_ROLES).freeze

  NON_ADVISOR_ROLES =
    [
      'Reader',
      'Rdr',
      'Outside Reader',
      'Engineers Thesis/Project Adv',
      'Doct Dissert Reader (AC)',
      'Doct Dissert Rdr (NonAC)',
      'Outside Dissert Reader (AC)'
    ].freeze

  belongs_to :submission
  validates :name, presence: true
  validates :position, presence: true

  scope :advisors, -> { where(readerrole: ADVISOR_ROLES) }
  scope :non_advisors, -> { where(readerrole: NON_ADVISOR_ROLES) }

  def signature_page_role
    return 'Primary Adviser' if readerrole.in?(PRIMARY_ADVISOR_ROLES)
    return 'Co-Adviser' if readerrole.in?(COADVISOR_ROLES)

    nil
  end
end
