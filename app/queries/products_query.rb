# frozen_string_literal: true

class ProductsQuery < BaseQuery
  def query(params:, includes: nil)
    scoped = @initial_scope.i18n
    scoped = includes(scoped, includes) if includes.present?
    scoped = filter(scoped, params)
    sorts(scoped, params)
  end

  private def filter(scoped, params)
    query = params[:query]
    return scoped if query.blank?

    scoped.where("barcode ILIKE ?", query)
      .or(scoped.where(id: scoped.search(query)))
  end

  private def sorts(scoped, params)
    sort_column = @policy.permitted_sort_attributes
      .include?(params[:sort]) ? params[:sort] : :name
    sort_direction = %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"

    scoped.order(sort_column => sort_direction)
  end
end
