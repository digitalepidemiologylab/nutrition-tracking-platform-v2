# frozen_string_literal: true

class BadgeComponent < ApplicationComponent
  def initialize(color: nil)
    @text_css_classes =
      case color
      when :brand
        "bg-brand text-white"
      when :green
        "bg-positive text-white"
      else
        "bg-gray-200 text-gray-800"
      end
  end
end
