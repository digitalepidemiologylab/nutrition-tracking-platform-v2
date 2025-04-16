# frozen_string_literal: true

module Collab
  class SidebarComponent < ApplicationComponent
    renders_one :bottom_nav, "BottomNavComponent"
    renders_many :items, "ItemComponent"
    renders_many :bottom_items, "ItemComponent"

    class ItemComponent < ApplicationComponent
      renders_one :icon, IconComponent

      def initialize(text:, url:, icon:, active: false)
        @text, @url, @icon, @active = text, url, icon, active
      end
    end

    class BottomNavComponent < ApplicationComponent
      def initialize(items:)
        @items = items
      end

      def render?
        @items.present?
      end
    end
  end
end
