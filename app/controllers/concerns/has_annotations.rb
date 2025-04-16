# frozen_string_literal: true

module HasAnnotations
  extend ActiveSupport::Concern

  private def set_annotations(initial_scope:)
    store_query_params
    @annotations = AnnotationsQuery
      .new(
        initial_scope: initial_scope,
        policy: policy([:collab, Annotation])
      )
      .query(
        params: params,
        includes: [
          :intakes,
          :last_intake,
          :participation,
          :products,
          annotation_items: [:product, :food],
          dish: [:user, dish_image: {data_attachment: :blob}]
        ]
      )
    @pagy, @annotations = pagy(@annotations, page_param: :annotations_page)

    @aasm_states = Annotation.aasm.states
    @available_cohorts = policy_scope(Cohort).order(:name)
  end

  private def store_query_params
    new_query_params = JSON.parse(cookies[:annotations_query_params] || "{}")
      .merge(request.query_parameters)
      .except("annotations_page")

    cookies.permanent[:annotations_query_params] = new_query_params.to_json
  end
end
