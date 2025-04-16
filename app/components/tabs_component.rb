# frozen_string_literal: true

class TabsComponent < ApplicationComponent
  renders_many :tabs, "TabComponent"

  class TabComponent < ApplicationComponent
    def initialize(url:, active: false)
      @url = url
    end

    def before_render
      @active = helpers.current_page?(@url)
    end

    def render?
      content.present?
    end

    def call
      tag.a(
        content,
        href: @url,
        class: set_classes,
        aria: {
          current: @active ? "page" : "false"
        }
      )
    end

    private def set_classes
      if @active
        "border-brand text-brand whitespace-nowrap py-4 px-1 border-b-2 font-medium text-sm"
      else
        "border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300 whitespace-nowrap py-4 px-1 border-b-2 font-medium text-sm"
      end
    end
  end
end
