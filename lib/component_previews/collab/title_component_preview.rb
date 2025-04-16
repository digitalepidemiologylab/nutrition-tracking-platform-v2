# frozen_string_literal: true

module Collab
  class TitleComponentPreview < ViewComponent::Preview
    def default
      render(Collab::TitleComponent.new) do |tc|
        tc.with_action { "<a href='' class='btn btn-primary'>home</a>" }
        "The Title"
      end
    end
  end
end
