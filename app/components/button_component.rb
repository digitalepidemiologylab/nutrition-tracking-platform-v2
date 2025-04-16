# frozen_string_literal: true

class ButtonComponent < ApplicationComponent
  renders_one :icon, IconComponent

  def initialize(level: :primary, type: :button, icon: nil, small: false, autofocus: false)
    @level = level
    @type = type
    @size_classes = small ? "text-xs px-2 py-1" : nil
    @autofocus = autofocus
    validate!
  end

  private def validate!
    validate_inclusion_of(:level, value: @level, accepted_values: %i[primary secondary])
    validate_inclusion_of(:type, value: @type, accepted_values: %i[button submit reset])
  end
end
