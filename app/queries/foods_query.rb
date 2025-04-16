# frozen_string_literal: true

class FoodsQuery < BaseQuery
  def query(params:, includes: nil)
    scoped = @initial_scope.i18n
    scoped = includes(scoped, includes) if includes.present?
    scoped = filter(scoped, params)
    scoped = search_by_name(scoped, params)
    sorts(scoped, params)
  end

  private def filter(scoped, params)
    filter_by_food_lists(scoped, params)
  end

  private def filter_by_food_lists(scoped, params)
    return scoped if params[:food_list_ids].blank?

    scoped.where(food_list_id: params[:food_list_ids])
  end

  private def search_by_name(scoped, params)
    return scoped if params[:query].blank?

    query = CGI.unescape(params[:query])
    scoped.search(query)
  end

  private def sorts(scoped, params)
    sort_column = @policy.permitted_sort_attributes
      .include?(params[:sort]) ? params[:sort] : :name
    sort_direction = %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"

    if sort_column == "food_list"
      scoped = scoped.joins(:food_list)
      sort_column = "food_lists.name"
    end

    scoped.order(sort_column => sort_direction)
  end
end
