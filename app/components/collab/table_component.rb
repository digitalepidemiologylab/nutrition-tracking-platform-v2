# frozen_string_literal: true

module Collab
  class TableComponent < ApplicationComponent
    renders_one :title, "TitleComponent"
    renders_one :form, "FormComponent"
    renders_many :head_tds, "HeadTdComponent"
    renders_many :rows, "RowComponent"

    def initialize(striped: false, force_show_table: false, table_id: nil, tbody_id: nil)
      @striped = striped
      @force_show_table = force_show_table
      @table_id = table_id
      @tbody_id = tbody_id
    end

    class TitleComponent < ApplicationComponent
      renders_one :additional_element

      def render?
        content.present?
      end
    end

    class FormComponent < ApplicationComponent
      renders_many :selects, "SelectComponent"

      def initialize(stimulus_controller:, turbo_frame:)
        @stimulus_controller = stimulus_controller
        @turbo_frame = turbo_frame
      end

      def render?
        content.present?
      end

      class SelectComponent < ApplicationComponent
        def initialize(attribute:, options:, selected:, label: nil, action: nil)
          @attribute = attribute
          @label = label
          @options = options
          @selected = selected
          @action = action
        end
      end
    end

    class HeadTdComponent < ApplicationComponent
      def initialize(align: :left, column: nil, params: {})
        @align = align
        @column = column
        @params = params
        @params = @params.to_unsafe_h if @params.is_a?(ActionController::Parameters)
        @align_class = case @align
        when :right
          "text-right"
        else
          "text-left"
        end
        validate!
      end

      def call
        tag.th(
          link,
          class: "px-6 py-3 #{@align_class} text-xs font-medium text-gray-500 uppercase tracking-wider",
          scope: "col"
        )
      end

      private def validate!
        validate_inclusion_of(:align, value: @align, accepted_values: %i[left right])
      end

      private def link
        return content if @column.blank?

        sorting_link
      end

      private def sorting_link
        classes = ["whitespace-nowrap"]
        direction = "asc"
        carret = bidirectional_carret
        if @params[:sort] == @column.to_s
          classes << "text-brand"
          if @params[:direction] == "asc"
            direction = "desc"
            carret = render(IconComponent.new("caret-up-fill"))
          else
            carret = render(IconComponent.new("caret-down-fill"))
          end
        end

        link_to(
          safe_join([content, carret]),
          @params.merge!(sort: @column, direction: direction),
          class: classes.join(" "),
          data: {turbo_action: "advance"}
        )
      end

      # Unfortunately Phosphor doesn't include a bidirectional carret
      private def bidirectional_carret
        tag.svg(
          xmlns: "http://www.w3.org/2000/svg",
          width: "15",
          height: "12",
          style: "display: inline",
          fill: "rgba(156, 163, 175, var(--tw-text-opacity))"
        ) { tag.path(d: "m3.5,4 4-4 4,4zm0,1 4,4 4-4z") }
      end
    end

    class RowComponent < ApplicationComponent
      renders_many :row_tds, "RowTdComponent"

      def initialize(id: nil)
        @id = id
      end

      class RowTdComponent < ApplicationComponent
        def initialize(additional_classes: nil)
          @additional_classes = additional_classes
        end

        def call
          tag.td(content, class: "px-6 py-4 text-sm #{@additional_classes}")
        end
      end
    end
  end
end
