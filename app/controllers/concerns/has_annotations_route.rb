# frozen_string_literal: true

module HasAnnotationsRoute
  extend ActiveSupport::Concern

  included do
    helper_method :collab_annotations_path_with_query_params
  end

  def collab_annotations_path_with_query_params
    query_params = JSON.parse(cookies[:annotations_query_params] || "{}")
    if query_params.blank?
      query_params[:filter] = {status: :annotatable}
    end
    collab_annotations_path(query_params)
  end
end
