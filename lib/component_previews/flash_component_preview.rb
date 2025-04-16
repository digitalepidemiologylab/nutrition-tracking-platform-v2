# frozen_string_literal: true

class FlashComponentPreview < ViewComponent::Preview
  def error
    render(FlashComponent.new({flash: [:error, "Something weird happened"]}))
  end

  def notice
    render(FlashComponent.new({flash: [:notice, "Something nice happened"]}))
  end
end
