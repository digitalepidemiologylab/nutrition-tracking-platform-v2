# frozen_string_literal: true

module Collab
  module AnnotationItems
    class FormComponent < ApplicationComponent
      include Turbo::FramesHelper

      KCAL_UNIT_ID = "kcal"

      with_collection_parameter :annotation_item

      def initialize(annotation_item:, units:, collaborator:, selected: false)
        @annotation_item = annotation_item
        @annotation = annotation_item.annotation
        @food = annotation_item.food
        @food_set = annotation_item.food_set
        @food_lists = @annotation.food_lists
        @foods = @food_set&.foods
          &.i18n
          &.includes(:translations)
          &.of_food_lists(@food_lists)
          &.order(:name)
        @options = options
        @units = units
        @selected = selected
        @disabled = !Collab::AnnotationItemPolicy.new(collaborator, @annotation_item).update?
        @disabled_classes = @disabled ? "cursor-not-allowed bg-gray-100 border-gray-200 placeholder-gray-400 text-gray-400" : nil
        @position = @annotation_item&.position
        @color_index = @annotation_item&.color_index
        @displayed_calculated_consumed_info = displayed_calculated_consumed_info
        @additional_data = additional_data
      end

      # Not private to be testable
      def options
        if @food_set.present?
          grouped_options = {}
          grouped_options["Food Set - `#{@food_set.name}`"] = @foods.map { |food| food_option(food) }
          if @food.food_sets.exclude?(@food_set)
            grouped_options["Other foods"] = [food_option(@food)]
          end
          grouped_options_for_select(grouped_options, @food&.id)
        else
          options_for_select([food_option(@food)], @food&.id)
        end
      end

      # Not private to be testable
      def displayed_calculated_consumed_info
        calculated_kcal = displayed_consumed_kcal
        calculated_values = [displayed_calculated_consumed_quantity].compact
        calculated_values << if calculated_values.present? && calculated_kcal.present?
          "(#{calculated_kcal})"
        elsif calculated_kcal.present?
          calculated_kcal
        end
        calculated_values.compact.presence&.unshift("=")&.join(" ")
      end

      # Not private to be testable
      def additional_data
        data = {}
        if @annotation_item.ml_confidence
          data[:ml_confidence] = @annotation_item.ml_confidence
        end
        if @annotation_item.food_set_id
          data[:food_set_id] = @annotation_item.food_set_id
        end
        if @annotation_item.original_food_set_id && @annotation_item.food_set_id != @annotation_item.original_food_set_id
          data[:original_food_set_id] = @annotation_item.original_food_set_id
        end
        data
      end

      private def displayed_calculated_consumed_quantity
        return if @annotation_item.consumed_percent.blank? && !show_hundred_percent?

        @annotation_item.consumed_quantity = show_hundred_percent? ? 100 : @annotation_item.consumed_percent
        @annotation_item.consumed_unit_id = nil

        displayed_calculated_consumed_quantity = (@annotation_item.present_quantity || 0) * @annotation_item.consumed_quantity / 100

        "#{displayed_calculated_consumed_quantity} #{@annotation_item.present_unit_id}"
      end

      private def displayed_consumed_kcal
        return unless @annotation_item.consumed_kcal

        "#{@annotation_item.consumed_kcal.round(2)} #{KCAL_UNIT_ID}"
      end

      private def show_hundred_percent?
        return false if @annotation_item.consumed_percent.present?

        @annotation_item.consumed_quantity.blank? ||
          (
            @annotation_item.consumed_quantity == @annotation_item.present_quantity &&
            @annotation_item.consumed_unit == @annotation_item.present_unit
          )
      end

      private def food_option(food)
        return unless food

        [food.name, food.id, {data: {unit_id: @annotation_item.present_unit_id, portion_quantity: @annotation_item.present_quantity}}]
      end
    end
  end
end
