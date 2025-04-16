# frozen_string_literal: true

class IconComponent < ApplicationComponent
  def initialize(type, classes: nil)
    @type = type
    @all_classes = all_classes(classes)
  end

  private def all_classes(classes)
    css_classes = ["ph-#{@type}"]
    css_classes += Array(classes) if classes.present?
    css_classes.compact.join(" ")
  end
end
