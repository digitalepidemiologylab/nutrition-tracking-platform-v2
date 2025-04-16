# frozen_string_literal: true

module Collab
  class BreadcrumbsComponent < ApplicationComponent
    def initialize(crumbs: [])
      @crumbs = crumbs
    end

    def render?
      @crumbs.present?
    end

    class CrumbComponent < ApplicationComponent
      def initialize(crumb:, crumb_counter: 0)
        @text = crumb[:text]
        @url = crumb[:url]
        @crumb_counter = crumb_counter
        @css_classes = "text-sm font-medium text-gray-500 hover:text-gray-700"
        @css_classes += " ml-2" if @crumb_counter.positive?
      end
    end
  end
end
