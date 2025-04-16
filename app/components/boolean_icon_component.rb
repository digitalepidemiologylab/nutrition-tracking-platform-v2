# frozen_string_literal: true

class BooleanIconComponent < IconComponent
  def initialize(boolean)
    super(
      boolean ? "check-circle-fill" : "x-circle-fill",
      classes: "#{boolean ? "text-positive" : "text-brand"} text-lg"
    )
  end
end
