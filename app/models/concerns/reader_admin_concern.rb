# frozen_string_literal: true

# Concern for supporting admin for readers.
# This is intended to encapsulate all ActiveAdmin-related logic for readers.
module ReaderAdminConcern
  extend ActiveSupport::Concern

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

  class_methods do
    # associations that are searchable via activeadmin
    def ransackable_associations(_auth_object = nil)
      ['submission']
    end

    # attributes that are searchable via activeadmin
    def ransackable_attributes(_auth_object = nil)
      %w[created_at finalreader id name position prefix readerrole
         submission_id suffix sunetid type univid updated_at]
    end
  end
end
