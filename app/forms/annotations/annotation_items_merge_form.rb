# frozen_string_literal: true

module Annotations
  class AnnotationItemsMergeForm
    include ActiveModel::Model

    attr_reader :annotation, :parent_annotation_item, :annotation_items

    validate :annotation_items_presence

    def initialize(annotation:)
      @annotation = annotation
      @annotation_items = []
      @parent_annotation_item = nil
    end

    def save(params)
      @annotation_items = query_annotation_items(params: params)
      return false unless valid?

      all_annotation_items = @annotation_items.dup
      @parent_annotation_item = @annotation_items.shift
      parent_polygon_set = @parent_annotation_item.polygon_set || @parent_annotation_item.build_polygon_set
      new_parent_polygons = merge_polygons(annotation_items: all_annotation_items)
      new_present_quantity = all_annotation_items.filter_map(&:present_quantity).sum
      new_consumed_quantity = all_annotation_items.filter_map(&:consumed_quantity).sum

      merge_annotation_items(
        parent_polygon_set: parent_polygon_set,
        new_parent_polygons: new_parent_polygons,
        new_present_quantity: new_present_quantity,
        new_consumed_quantity: new_consumed_quantity
      )
    end

    private def query_annotation_items(params:)
      @annotation.annotation_items
        .where(id: params[:annotation_item_ids])
        .order(position: :desc).to_a
    end

    private def merge_polygons(annotation_items:)
      annotation_items
        .filter_map { |annotation_item| annotation_item.polygon_set&.polygons }
        .sum([])
    end

    private def merge_annotation_items(parent_polygon_set:, new_parent_polygons:, new_present_quantity:, new_consumed_quantity:)
      consumed_unit = @parent_annotation_item.consumed_unit.presence || @parent_annotation_item.present_unit
      ActiveRecord::Base.transaction do
        if new_parent_polygons.present?
          parent_polygon_set.update!(polygons: new_parent_polygons)
        else
          parent_polygon_set.destroy!
        end
        parent_annotation_item.update!(
          present_quantity: new_present_quantity,
          consumed_unit: consumed_unit,
          consumed_quantity: new_consumed_quantity
        )
        @annotation_items.each(&:destroy!)
      end
    rescue ActiveRecord::RecordInvalid => e
      errors.add(:base, e.message)
      false
    end

    private def annotation_items_presence
      return if @annotation_items.size > 1

      errors.add(:base, I18n.t("activemodel.errors.models.annotations.annotation_items_merge_forms.attributes.base.size_merge"))
    end
  end
end
