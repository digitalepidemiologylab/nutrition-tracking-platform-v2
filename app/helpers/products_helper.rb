# frozen_string_literal: true

module ProductsHelper
  def product_default_image_url(product:)
    return product.image_url if product.image_url

    product_image = product.product_images&.first
    return unless product_image

    default_image = product_image.data.variant(:thumb).processed ? product_image.data.variant(:thumb) : product_image.data
    url_for(default_image)
  end
end
