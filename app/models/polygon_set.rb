# frozen_string_literal: true

class PolygonSet < ApplicationRecord
  belongs_to :dish_image, inverse_of: :polygon_sets
  belongs_to :annotation_item, inverse_of: :polygon_set
  belongs_to :segmentation_client, optional: true, inverse_of: :polygon_sets

  validates :polygons, presence: true
  validates :dish_image_id, uniqueness: {scope: :annotation_item_id}

  before_validation :set_dish_image

  def polygons=(polygons)
    polygons = JSON.parse(polygons) if polygons.is_a?(String)
    super
  end

  private def set_dish_image
    return if dish_image.present?

    self.dish_image = annotation_item&.annotation&.dish&.dish_image
  end
end
