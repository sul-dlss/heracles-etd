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

  def to_s
    name.concat(display_suffix).concat(display_role)
  end

  def signature_page_role
    return 'Primary Advisor' if readerrole.in?(PRIMARY_ADVISOR_ROLES)
    return 'Co-Advisor' if readerrole.in?(COADVISOR_ROLES)

    nil
  end

  # Helps the sort algorithm in `.sorted_list` by ensuring primary advisors
  # appear before co-advisors, and co-advisors appear before non-advisors (plain
  # ol' readers).
  def self.sort_order_based_on_role_label(role_label)
    return 1 if role_label.in?(PRIMARY_ADVISOR_ROLES)
    return 2 if role_label.in?(COADVISOR_ROLES)

    3
  end

  # Helps the sort algorithm in `.sorted_list` by ensuring internal reading
  # committee members appear before external ones. Two values are expected for
  # the `role_type` arg: 'int' and 'ext'
  def self.sort_order_based_on_role_type(role_type)
    return 2 if role_type == 'ext'

    1
  end

  # Sort readers:
  #   * First, according to primary adv/co-adv/non-adv (in that order)
  #   * Second, according to internal/external (in that order)
  #   * Third, according to name
  def self.sorted_list(readers) # rubocop:disable Metrics/AbcSize
    # If there is only one reader in the document, it returns a hash rather than a list with one element.
    raw_readers = Array.wrap(readers)
    sorted_readers = raw_readers.sort_by do |reader|
      [
        sort_order_based_on_role_label(reader['readerrole']),
        sort_order_based_on_role_type(reader['type']),
        reader['name']
      ]
    end

    # Add position to each reader, and clean out unnecessary whitespace in sunetid, univid, prefix
    sorted_readers.map.with_index(1) do |reader, index|
      reader.merge('position' => index,
                   'sunetid' => reader['sunetid']&.strip.presence,
                   'univid' => reader['univid']&.strip.presence,
                   'suffix' => reader['suffix']&.strip.presence)
    end
  end

  private

  def display_suffix
    return '' if suffix.blank?

    ", #{suffix}"
  end

  def display_role
    return '' if readerrole.blank?
    return '' if signature_page_role.blank?

    " (#{signature_page_role})"
  end
end
