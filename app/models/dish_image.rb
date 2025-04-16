# frozen_string_literal: true

class DishImage < ApplicationRecord
  include BaseImage

  belongs_to :dish, inverse_of: :dish_image
  has_many :segmentations, inverse_of: :dish_image, dependent: :destroy
  has_many :polygon_sets, inverse_of: :dish_image, dependent: :destroy
end
