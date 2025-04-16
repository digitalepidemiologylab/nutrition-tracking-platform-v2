# frozen_string_literal: true

module Collab
  class TitleComponent < ApplicationComponent
    renders_many :actions, "Action"

    def initialize(max_width: "full")
      @max_width = max_width
    end

    def render?
      content.present?
    end

    class Action < ApplicationComponent
      def render?
        content.present?
      end

      def call
        content
      end
    end
  end
end
