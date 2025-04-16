# frozen_string_literal: true

module Collab
  class PanelComponent < ApplicationComponent
    renders_one :title, "TitleComponent"

    def initialize(additional_classes: nil)
      @additional_classes = additional_classes
    end

    def render?
      content.present?
    end

    class TitleComponent < ApplicationComponent
      def render?
        content.present?
      end
    end
  end
end
