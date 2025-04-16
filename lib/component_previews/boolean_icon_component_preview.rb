# frozen_string_literal: true

class BooleanIconComponentPreview < ViewComponent::Preview
  def true
    render(BooleanIconComponent.new(true))
  end

  def false
    render(BooleanIconComponent.new(false))
  end
end
