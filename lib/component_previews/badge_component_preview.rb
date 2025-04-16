# frozen_string_literal: true

class BadgeComponentPreview < ViewComponent::Preview
  def default
    render(BadgeComponent.new) do
      "badge"
    end
  end

  def with_green_color
    render(BadgeComponent.new(color: :green)) do
      "badge"
    end
  end

  def with_brand_color
    render(BadgeComponent.new(color: :brand)) do
      "badge"
    end
  end
end
