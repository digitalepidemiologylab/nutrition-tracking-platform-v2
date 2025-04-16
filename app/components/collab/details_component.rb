# frozen_string_literal: true

module Collab
  class DetailsComponent < ApplicationComponent
    renders_one :title, Collab::PanelComponent::TitleComponent
    renders_many :details, "DetailComponent"

    class DetailComponent < ApplicationComponent
      def initialize(label:, value:)
        @label = label
        @value = value
      end
    end
  end
end
