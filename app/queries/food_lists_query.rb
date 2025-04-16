# frozen_string_literal: true

class FoodListsQuery < BaseQuery
  def query(params:, includes: nil)
    scoped = @initial_scope
    scoped = includes(scoped, includes) if includes.present?
    scoped = filter(scoped, params)
    sorts(scoped, params)
  end

  private def filter(scoped, params)
    filter_by_name(scoped, params)
  end

  private def filter_by_name(scoped, params)
    return scoped if params[:query].blank?

    wild_sanitized_params = "%#{ActiveRecord::Base.sanitize_sql_like(params[:query])}%"
    scoped.where("food_lists.name ILIKE ?", wild_sanitized_params)
  end

  private def sorts(scoped, params)
    sort_column = @policy.permitted_sort_attributes
      .include?(params[:sort]) ? params[:sort] : :name
    sort_direction = %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"

    if sort_column == "country"
      return order_by_translated_associated_model_attribute(
        scoped,
        model: sort_column,
        attribute: :name,
        direction: sort_direction
      )
    end

    scoped.order(sort_column => sort_direction)
  end
end
