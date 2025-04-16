# frozen_string_literal: true

module Collab
  class CommentsController < BaseController
    before_action :set_annotation
    before_action :set_timezone

    def index
      @comments = policy_scope(@annotation.comments).order(created_at: :asc)
      authorize(@comments)
    end

    def create
      form = Comments::CreateForm.new(annotation: @annotation, collaborator: current_collaborator, view_context: view_context)
      @comment = form.comment
      authorize(@comment)
      flash.now[:alert] = t(".failure") unless form.save(permitted_attributes(@comment))
    end

    private def set_annotation
      @annotation = Annotation.find(params[:annotation_id])
    end

    private def set_timezone
      @timezone = current_collaborator.timezone
    end
  end
end
