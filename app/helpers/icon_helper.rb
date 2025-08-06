# frozen_string_literal: true

# Helper for rendering icons.
module IconHelper
  extend ActionView::Helpers::TagHelper

  def icon(icon_classes:, classes: nil, **)
    all_classes = ComponentSupport::CssClasses.merge(icon_classes, classes)
    content_tag(:i, nil, class: all_classes, **)
  end

  def danger_icon(**)
    icon(icon_classes: 'bi bi-exclamation-triangle-fill', **)
  end

  def note_icon(**)
    icon(icon_classes: 'bi bi-exclamation-circle-fill', **)
  end

  def success_icon(**)
    icon(icon_classes: 'bi bi-check-circle-fill', **)
  end

  def info_icon(fill: true, **)
    icon(icon_classes: ['bi', fill ? 'bi-info-circle-fill' : 'bi-info-circle'], **)
  end

  def warning_icon(**)
    icon(icon_classes: 'bi bi-exclamation-circle-fill', **)
  end

  def edit_icon(**)
    icon(icon_classes: 'bi bi-pencil', **)
  end

  def x_circle_icon(**)
    icon(icon_classes: 'bi bi-x-circle', **)
  end
end
