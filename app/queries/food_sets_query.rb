# frozen_string_literal: true

class FoodSetsQuery < BaseQuery
  def query(params:, includes: nil)
    scoped = @initial_scope.i18n
    scoped = includes(scoped, includes) if includes.present?
    scoped = scoped.search(params[:query]) if params[:query].present?
    sorts(scoped, params)
  end

  private def sorts(scoped, params)
    sort_column = @policy.permitted_sort_attributes
      .include?(params[:sort]) ? params[:sort].to_sym : :name
    sort_direction = %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"

    return sort_by_lower_name(scoped, direction: sort_direction) if sort_column == :name

    scoped.order(sort_column => sort_direction)
  end

  private def sort_by_lower_name(scoped, direction:)
    locales = I18n.fallbacks[I18n.locale]
    translations_join = locales.map do |locale|
      <<~SQL.squish
        JOIN food_set_translations fst_#{locale}
          ON fst_#{locale}.food_set_id = food_sets.id
          AND fst_#{locale}.locale = '#{locale}'
      SQL
    end
    join_query = translations_join.join(" ")

    order_query = <<~SQL.squish
      UNACCENT(LOWER(COALESCE(
        #{locales.map { |locale| "fst_#{locale}.name" }.join(", ")},
      ''))) #{direction}
    SQL

    scoped
      .joins(Arel.sql(join_query))
      .order(Arel.sql(ActiveRecord::Base.sanitize_sql_for_order(order_query)))
  end
end
