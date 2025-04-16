# frozen_string_literal: true

module Annotations
  class AnnotationItemsDestroyForm
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

      destroy_annotation_items
    end

    private def query_annotation_items(params:)
      @annotation.annotation_items
        .includes(:polygon_set)
        .where(id: params[:annotation_item_ids])
        .order(position: :desc).to_a
    end

    private def destroy_annotation_items
      ActiveRecord::Base.transaction do
        @annotation_items.each(&:destroy!)
      end
    rescue => e
      errors.add(:base, e.message)
      false
    end

    private def annotation_items_presence
      return if @annotation_items.present?

      errors.add(:base, I18n.t("activemodel.errors.models.annotations.annotation_items_merge_forms.attributes.base.size_destroy"))
    end
  end
end
