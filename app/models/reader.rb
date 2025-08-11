# frozen_string_literal: true

# Model for readers associated with submissions
class Reader < ApplicationRecord
  self.inheritance_column = nil # allows us to use 'type' for something else, i.e. ["int"ernal | "ext"ernal]

  belongs_to :submission
  validates :name, presence: true
  validates :position, presence: true
end
