# frozen_string_literal: true

module Api
  module V2
    class CommentsController < BaseController
      before_action :set_annotation

      def index
        authorize(Comment)
        include_directive = permitted_include_directive(Comment, params[:include])
        comments = policy_scope(@annotation.comments.includes(include_directive))
        pagy, comments = pagy(comments)
        render jsonapi: comments, include: include_directive, meta: pagy_metadata(pagy), status: :ok
      end

      def create
        form = Comments::CreateForm.new(annotation: @annotation, user: current_api_v2_user, view_context: view_context)
        comment = form.comment
        authorize(comment)
        if form.save(permitted_attributes(comment).except(:type))
          render jsonapi: comment,
            include: permitted_include_directive(comment, params[:include]),
            status: :ok
        else
          render jsonapi_errors: comment.errors, status: :unprocessable_entity
        end
      end

      private def set_annotation
        @annotation = Annotation.find(params[:annotation_id])
      end
    end
  end
end
