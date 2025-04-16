# frozen_string_literal: true

module Collab
  class BreadcrumbsComponentPreview < ViewComponent::Preview
    def default
      render(Collab::BreadcrumbsComponent.new(crumbs: [{text: "1st crumb", url: "#"}, {text: "2nd crumb"}]))
    end
  end
end
