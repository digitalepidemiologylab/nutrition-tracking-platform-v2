# frozen_string_literal: true

class DropdownComponent < ApplicationComponent
  renders_one :icon, IconComponent
  renders_one :text
  renders_many :items, "ItemComponent"

  def initialize(size: nil, origin: :left)
    @size = size
    @origin = origin
    validate!
    @button_size = (@size == :small) ? "text-xs" : "text-sm"
    @icon_size = (@size == :small) ? "text-xl" : "text-lg"
    @origin_classes = (@origin == :right) ? "origin-top-right left-0" : "origin-top-left right-0"
  end

  private def validate!
    validate_inclusion_of(:size, value: @size, accepted_values: %i[small large])
    validate_inclusion_of(:origin, value: @origin, accepted_values: %i[right left])
  end

  class ItemComponent < ApplicationComponent
    def initialize(text:, url:, active: false, method: nil)
      @text, @url, @active, @method = text, url, active, method
    end

    def call
      params = {
        class: "#{@active ? "bg-gray-100 text-gray-800" : "text-gray-700"} block px-4 py-2 text-sm",
        role: "menuitem",
        tabindex: @active ? "0" : "-1"
      }
      if @method.present?
        params[:method] = @method
        button_to(@text, @url, params)
      else
        link_to(@text, @url, params)
      end
    end
  end
end
