# frozen_string_literal: true

module Public
  class HomeController < BaseController
    def show
      if collaborator_signed_in?
        location = if Collab::AnnotationPolicy.new(current_collaborator, nil).index?
          collab_annotations_path_with_query_params
        else
          collab_profile_path
        end
        redirect_to(location)
      end
    end
  end
end
