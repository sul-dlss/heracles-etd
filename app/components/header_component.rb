# frozen_string_literal: true

# Component for rendering page header.
class HeaderComponent < ApplicationComponent
  def initialize(current_user:, title:, subtitle:)
    @current_user = current_user
    @title = title
    @subtitle = subtitle
    super()
  end

  attr_reader :current_user, :title, :subtitle
end
