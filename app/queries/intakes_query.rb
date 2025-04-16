# frozen_string_literal: true

class IntakesQuery < BaseQuery
  DEFAULT_SORT = :created_at
  DEFAULT_DIRECTION = :desc

  def query(params: nil, includes: nil)
    includes = add_blob_to_includes(includes)
    scoped = includes(@initial_scope, includes)
    scoped = filter(scoped, params)
    sorts(scoped, params)
  end

  private def filter(scoped, params)
    scoped = filter_by_query(scoped, params)
    filter_by_updated_at_gt(scoped, params)
  end

  private def filter_by_query(scoped, params)
    query_param = params[:query]
    return scoped if query_param.blank?

    begin
      date = Date.parse(query_param)
      scoped.where("DATE(intakes.consumed_at) = ?", date)
    rescue
      filter_by_food_or_product(scoped, params)
    end
  end

  private def filter_by_food_or_product(scoped, params)
    query = params[:query]
    return scoped if query.blank?

    foods = Food.search(query)
    products_by_name = Product.search(query)
    products_by_barcode = Product.where("barcode ~ ?", query.scan(/\d+/).join)
    products = Product.where(id: products_by_name + products_by_barcode)
    scoped.joins(annotation: :annotation_items).merge(
      AnnotationItem.where(food_id: foods)
        .or(AnnotationItem.where(product_id: products))
    )
  end

  private def filter_by_updated_at_gt(scoped, params)
    updated_at_gt = params.dig(:filter, :updated_at_gt)
    return scoped if updated_at_gt.blank?

    updated_at_gt_datetime = begin
      updated_at_gt.to_datetime
    rescue Date::Error => e
      raise BadFilterParam, e.message
    end

    scoped.where("intakes.updated_at > ?", updated_at_gt_datetime)
  end

  private def sorts(scoped, params)
    sort_column = @policy&.permitted_sort_attributes&.include?(params[:sort]) ? params[:sort] : DEFAULT_SORT
    sort_direction = %w[asc desc].include?(params[:direction]) ? params[:direction] : DEFAULT_DIRECTION

    scoped.order(sort_column => sort_direction, :id => :asc)
  end

  private def add_blob_to_includes(includes)
    return includes unless includes&.dig(:annotation, :dish, :dish_image)

    includes.deep_merge(annotation: {dish: {dish_image: {data_attachment: :blob}}})
  end
end
