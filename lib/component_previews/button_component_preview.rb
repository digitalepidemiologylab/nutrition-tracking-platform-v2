# frozen_string_literal: true

class ButtonComponentPreview < ViewComponent::Preview
  def primary
    render(ButtonComponent.new) do
      "Button"
    end
  end

  def secondary
    render(ButtonComponent.new(level: :secondary)) do
      "Button"
    end
  end

  def type_submit
    render(ButtonComponent.new(type: :submit)) do
      "Submit"
    end
  end

  def with_icon
    render(ButtonComponent.new) do |c|
      c.with_icon(:lock, classes: "text-lg opacity-60")
      "Button"
    end
  end
end
