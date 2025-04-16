# frozen_string_literal: true

module Segmentations
  module Aicrowd
    class ParseService
      CONFIDENCE_THRESHOLD = ENV.fetch("AICROWD_CONFIDENCE_THRESHOLD_V3").to_f

      def initialize(segmentation:)
        @segmentation = segmentation
        @data = segmentation.response_body.dup.deep_symbolize_keys!
      end

      def call
        create_annotation_items
        @segmentation.process!
      end

      protected def create_annotation_items
        above_threshold_response_items = @data[:response]
          .filter_map do |response_item|
            response_item if response_item[:score] >= CONFIDENCE_THRESHOLD
          end
          # we sort the items by score to have the highest score associated with the highest position
          .sort_by { |item| item[:score] }
        create_records(above_threshold_response_items)
      end

      private def create_records(records_data)
        annotation = @segmentation.annotation
        ActiveRecord::Base.transaction do
          annotation.annotation_items.destroy_all

          records_data.each do |record_data|
            create_record(annotation: annotation, record_data: record_data)
          end
        end
      end

      private def create_record(annotation:, record_data:)
        # AIcrowd added 100_000 to all FoodSet category ids
        food_set_id = record_data[:category_id].to_i - 100_000
        food_set = FoodSet.find_by(id_v1: food_set_id)
        food_lists = annotation.participation.cohort.food_lists
        if food_set
          food = food_set.foods
            .of_food_lists(food_lists)
            .order_by_annotation_count(:desc)
            .first
          if food
            annotation_item = create_annotation_item(annotation: annotation, food_set: food_set, food: food)
            create_polygon_set(record_data: record_data, annotation_item: annotation_item)
          else
            Sentry.capture_message(
              "Unknown food for category_id returned by #{self.class}: `#{food_set_id}`",
              level: :info
            )
          end
        else
          Sentry.capture_message(
            "Unknown food set for category_id returned by #{self.class}: `#{record_data[:category_id]}`", level: :info
          )
        end
      end

      private def create_annotation_item(annotation:, food_set:, food:)
        # Here we call new then save! to run the `before_validation :set_color_index` callback
        # Weirdly, if we call create! directly, the callback is not run
        annotation_item = annotation.annotation_items.new(
          food_set: food_set,
          original_food_set: food_set,
          food: food,
          present_quantity: food.portion_quantity,
          present_unit: food.unit
        )
        annotation_item.save!
        annotation_item
      end

      private def create_polygon_set(record_data:, annotation_item:)
        polygons = relative_polygons(record_data[:polygons])
        return if polygons.empty?

        annotation_item.create_polygon_set!(
          dish_image: @segmentation.dish_image,
          segmentation_client: @segmentation.segmentation_client,
          polygons: polygons,
          ml_dimensions: [image_size[:w], image_size[:h]],
          ml_confidence: record_data[:score]
        )
      end

      private def image_size
        # data-size is stored as [width,height]
        @image_size ||= begin
          first_segment_data = @data[:response].first
          return unless first_segment_data

          size = first_segment_data.fetch(:size)
          {w: size.first, h: size.last}
        end
      end

      private def relative_polygons(absolute_polygons)
        image_w = image_size[:w].to_f
        image_h = image_size[:h].to_f

        absolute_polygons.map do |polygon|
          # get relative coordinates
          src_coordinates = polygon.map do |x, y|
            [(x / image_w).round(6), (y / image_h).round(6)]
          end

          filter_similar_coordinates(src_coordinates)
        end
      end

      private def filter_similar_coordinates(src_coordinates)
        # we drop a coordinate if it to similar to the previous one
        previous_coordinate = src_coordinates.first
        new_src_coordinates = [previous_coordinate]
        src_coordinates.drop(1).each do |src_coordinate|
          similar = (
            (src_coordinate.first - previous_coordinate[0]).abs +
            (src_coordinate.second - previous_coordinate[1]).abs
          ) < 0.03
          next if similar

          new_src_coordinates << src_coordinate
          previous_coordinate = src_coordinate
        end
        new_src_coordinates
      end
    end
  end
end
