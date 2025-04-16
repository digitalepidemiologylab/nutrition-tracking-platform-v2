# frozen_string_literal: true

module Collab
  class PanelComponentPreview < ViewComponent::Preview
    def default
      render(PanelComponent.new) do
        tag.p("panel", class: "px-4 py-5 sm:px-6")
      end
    end

    def with_title
      render(PanelComponent.new) do |component|
        component.title { "A title" }
        tag.p("panel", class: "border-t border-gray-200 px-4 py-5 sm:px-6")
      end
    end
  end
end
