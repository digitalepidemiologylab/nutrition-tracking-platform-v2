# frozen_string_literal: true

class UsersQuery < BaseQuery
  DEFAULT_SORT = :email
  DEFAULT_DIRECTION = :asc

  def query(params:, includes: nil)
    scoped = @initial_scope
    scoped = includes(scoped, includes) if includes.present?
    scoped = filter(scoped, params)
    sorts(scoped, params)
  end

  private def filter(scoped, params)
    query = params[:query]
    return scoped if query.blank?

    scoped.includes(participations: :cohort).where("email ILIKE ?", "%#{query}%").or(
      scoped.includes(participations: :cohort).where(participations: {key: query})
    ).or(
      scoped.includes(participations: :cohort).where("cohorts.name ILIKE ?", "%#{query}%").references(:cohorts)
    )
  end

  private def sorts(scoped, params)
    sort_column = @policy.permitted_sort_attributes
      .include?(params[:sort]) ? params[:sort] : DEFAULT_SORT
    sort_direction = %w[asc desc].include?(params[:direction]) ? params[:direction] : DEFAULT_DIRECTION

    scoped.order(sort_column => sort_direction, :id => :asc)
  end
end
