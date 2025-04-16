# frozen_string_literal: true

require "pagy/extras/array"
class PaginationComponentPreview < ViewComponent::Preview
  include Pagy::Backend

  def default
    pagy, _ = pagy_array(150.times.to_a)
    render(PaginationComponent.new(pagy: pagy))
  end

  private def params
    {}
  end
end
