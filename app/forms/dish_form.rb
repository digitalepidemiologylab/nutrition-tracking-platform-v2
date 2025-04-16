# frozen_string_literal: true

class DishForm
  include ActiveModel::Model

  attr_reader :user, :dish, :dish_image, :annotation, :intake, :product

  validate :validate_children

  # Required for DishForm to be serializable
  def id
    nil
  end

  def initialize(user:)
    @user = user
  end

  # To follow the JSONAPI spec, return an array if the `has_many` relationship is nil
  # just like for a real ActiveRecord object
  def product_images
    @product_images || []
  end

  def save(params)
    @dish = build_dish(params)
    @dish_image = build_dish_image(params)
    @product = build_product(params)
    @product_images = build_product_images(params)
    @annotation = build_annotation(params)
    @intake = build_intake(params)
    return false if invalid?

    ActiveRecord::Base.transaction do
      children.each(&:save!)
    end

    # Makes sure dish is connected to its children
    @dish.reload
  end

  def children
    [@dish, @dish_image, @annotation, @intake, @product, @product_images].flatten.compact
  end

  private def build_dish(params)
    dish_params = params.dig(:params, :attributes, :dish)

    id = dish_params&.dig(:id)
    raise ActiveRecord::RecordNotUnique, "Dish already exists" if id.present? && Dish.exists?(id: id)

    @user.dishes.new(dish_params)
  end

  private def build_dish_image(params)
    dish_image_params = params.dig(:params, :attributes, :dish_image)
    return if dish_image_params.blank?

    data = dish_image_params.dig(:data)
    if data.present? && ActiveStorage::Blob.find_signed(data)&.attachments&.any?
      raise ActiveRecord::RecordNotUnique, "Dish image already attached"
    end

    @dish.build_dish_image(dish_image_params)
  end

  private def build_product(params)
    barcode = params.dig(:params, :attributes, :product, :barcode)
    return if barcode.blank?

    Product.find_or_initialize_by(barcode: barcode)
  end

  private def build_product_images(params)
    product_images_attributes = params.dig(:params, :attributes, :product_images)
    return if @product.nil? || product_images_attributes.blank?

    product_images_attributes.map do |product_image_params|
      @product.product_images.build(product_image_params)
    end
  end

  private def build_annotation(params)
    annotation = @dish.annotations.new(participation: @user.current_participation)
    return annotation if @product.nil?

    annotation.annotation_items.new(
      product: @product,
      consumed_unit: @product.unit,
      consumed_quantity: @product.portion_quantity
    )
    annotation
  end

  private def build_intake(params)
    intake_params = params.dig(:params, :attributes, :intake)

    id = intake_params&.dig(:id)
    raise ActiveRecord::RecordNotUnique, "Intake already exists" if id.present? && Intake.exists?(id: id)

    @annotation.intakes.new(intake_params)
  end

  private def validate_children
    children.compact.each do |child|
      promote_errors(child) if child.invalid?
    end
  end

  private def promote_errors(child)
    child.errors.each do |error|
      attributes_error = error.attribute.to_s.split(".").map do |attribute|
        child.class.human_attribute_name(attribute)
      end.uniq
      errors.add(
        "#{child.class.model_name.human} #{attributes_error.uniq.join(" ")}",
        error.message
      )
    end
  end
end
