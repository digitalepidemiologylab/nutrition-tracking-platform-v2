# frozen_string_literal: true

module Collab
  class DetailsComponentPreview < ViewComponent::Preview
    def default
      render(Collab::DetailsComponent.new) do |dc|
        dc.with_title { "A title" }
        5.times do |i|
          dc.with_detail(label: "Detail #{i}", value: "Detail value #{i}")
        end
      end
    end
  end
end
