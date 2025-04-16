# frozen_string_literal: true

module Collab
  class ProductsController < BaseController
    include HasAnnotations

    before_action :set_product, only: :show
    before_action :set_breadcrumbs

    def index
      authorize(Product)
      products = ProductsQuery
        .new(initial_scope: policy_scope(Product), policy: policy([:collab, Product]))
        .query(
          params: params,
          includes: [:unit, :translations]
        )
      @pagy, @products = pagy(products)
    end

    def show
      @product_images = @product.product_images
        .includes(data_attachment: :blob)
        .order(created_at: :desc)
        .limit(100)
      @breadcrumbs << {text: @product.name}
      set_associated_items
      list_annotations
    end

    private def set_product
      @product = Product.find(params[:id])
      authorize(@product)
    end

    private def set_associated_items
      @product_nutrients = @product.product_nutrients.includes(nutrient: :translations).order("nutrient_translations.name")
    end

    private def list_annotations
      initial_scope = policy_scope(Annotation)
        .joins(:annotation_items)
        .merge(AnnotationItem.where(product: @product))
      set_annotations(initial_scope: initial_scope)
    end

    private def set_breadcrumbs
      @breadcrumbs = [{text: t("layouts.collab.products"), url: collab_products_path}]
    end
  end
end
