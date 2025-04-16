# frozen_string_literal: true

class ProductImage < ApplicationRecord
  include BaseImage

  belongs_to :product, inverse_of: :product_images
end
