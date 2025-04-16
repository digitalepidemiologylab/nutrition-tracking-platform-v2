# frozen_string_literal: true

class IconComponentPreview < ViewComponent::Preview
  def lock_default
    render(IconComponent.new(:lock))
  end

  def lock_size_sm
    render(IconComponent.new(:lock, classes: "text-sm"))
  end

  def lock_size_lg
    render(IconComponent.new(:lock, classes: "text-lg"))
  end

  def lock_opacity_60
    render(IconComponent.new(:lock, classes: "opacity-60"))
  end

  def lock_color_brand
    render(IconComponent.new(:lock, classes: "text-brand"))
  end
end
