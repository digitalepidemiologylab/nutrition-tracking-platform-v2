# frozen_string_literal: true

module Comments
  class CreateForm < BaseActiveModelService
    attr_reader :annotation, :comment

    validate :validate_comment

    def initialize(annotation:, user: nil, collaborator: nil, view_context: nil)
      @annotation = annotation
      @comment = annotation.comments.new(user: user, collaborator: collaborator)
      @view_context = view_context
    end

    def save(params)
      comment.assign_attributes(params)
      return false if invalid?

      ActiveRecord::Base.transaction do
        comment.save!
        set_annotation_status
        comment.broadcast(view_context: @view_context) if @view_context
        create_push_notification
        true
      end
    end

    private def validate_comment
      promote_errors(comment) if comment.invalid?
      promote_errors(annotation) if annotation.invalid?
      annotation.errors.each do |error|
        next if error.attribute == :comments

        message = ["#{I18n.t("activerecord.models.annotation", count: 1)}:"]
        message << error.attribute if error.attribute != :base
        message << error.message
        comment.errors.add(:base, message.join(" "))
      end
    end

    private def create_push_notification
      return if comment.silent || comment.user == comment.dish.user

      Comments::CreatePushNotificationsJob.perform_later(comment: comment)
    end

    private def set_annotation_status
      set_annotation_status_by_user
      set_annotation_status_by_collaborator
    end

    private def set_annotation_status_by_user
      annotation = comment.annotation
      return if !comment.user ||
        comment.silent ||
        !annotation.may_open_annotation?

      annotation.open_annotation!
    end

    private def set_annotation_status_by_collaborator
      annotation = comment.annotation
      return if !comment.collaborator ||
        comment.silent ||
        !annotation.may_ask_info?

      annotation.ask_info!
    end
  end
end
