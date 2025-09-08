# frozen_string_literal: true

# Support methods for generating signature pages
class SignaturePageSupport
  def self.augmented_dissertation_path(dissertation_path:)
    dissertation_path.sub('.pdf', '-augmented.pdf')
  end
end
