# frozen_string_literal: true

class AnnotationsQuery < BaseQuery
  def query(params:, includes: [])
    scoped = @initial_scope
    scoped = includes(scoped, includes)
    scoped = filter(scoped, params)
    sorts(scoped, params)
  end

  private def filter(scoped, params)
    scoped = filter_by_status(scoped, params)
    filter_by_cohort(scoped, params)
  end

  private def filter_by_status(scoped, params)
    status = params.dig(:filter, :status)
    return scoped if status.blank? || status.casecmp("all").zero?
    raise(BadFilterParam, "Status not supported") unless status.to_sym.in?(Annotation.aasm.states.map(&:name))

    scoped.where(status: status)
  end

  private def filter_by_cohort(scoped, params)
    cohort_id = params.dig(:filter, :cohort_id)
    return scoped if cohort_id.blank? || cohort_id.casecmp("all").zero?

    cohort_id = nil if cohort_id.casecmp("none").zero?
    scoped
      .joins(participation: :cohort)
      .where(cohorts: {id: cohort_id})
  end

  private def sorts(scoped, params)
    sort_column = @policy.permitted_sort_attributes
      .include?(params[:sort]) ? params[:sort].to_s : "intakes.consumed_at"

    sort_direction = %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"

    order_params = {sort_column => sort_direction}

    if sort_column == "intakes.consumed_at"
      scoped = scoped
        .select("annotations.*, max(intakes.consumed_at) as last_consumed_at")
        .left_joins(:intakes)
        .group("annotations.id")
      order_params = "max(intakes.consumed_at) #{sort_direction}, annotations.created_at DESC"
    else
      order_params[:created_at] ||= "desc"
    end

    scoped.order(order_params)
  end
end
