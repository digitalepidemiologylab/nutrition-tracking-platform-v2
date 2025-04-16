# frozen_string_literal: true

class Comment < ApplicationRecord
  has_paper_trail on: %i[destroy]

  belongs_to :annotation, inverse_of: :comments
  belongs_to :user, inverse_of: :comments, optional: true
  belongs_to :collaborator, inverse_of: :comments, optional: true
  has_many :push_notifications, inverse_of: :comment, dependent: :destroy

  validates :message, presence: true
  validates :user, presence: {unless: :collaborator}, absence: {if: :collaborator}
  validates :collaborator, presence: {unless: :user}, absence: {if: :user}

  after_commit :touch_intakes

  delegate :dish, to: :annotation

  def broadcast(view_context:)
    broadcast_append_to([annotation, :comments], html: render_comment(view_context: view_context), target: ActionView::RecordIdentifier.dom_id(annotation, :comments))
  end

  private def touch_intakes
    annotation.intakes.touch_all
  end

  private def render_comment(view_context:)
    Collab::Annotations::CommentComponent.new(comment: self, timezone: timezone, comment_counter: annotation.comments.count, highlight: true).render_in(view_context)
  end

  private def timezone
    return "UTC" unless collaborator

    collaborator.timezone
  end
end
