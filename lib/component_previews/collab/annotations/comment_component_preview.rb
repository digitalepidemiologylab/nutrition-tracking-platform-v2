# frozen_string_literal: true

module Collab
  module Annotations
    class CommentComponentPreview < ViewComponent::Preview
      def for_user
        render(
          Collab::Annotations::CommentComponent.new(
            comment: Comment.create(message: "test", user: User.new, created_at: Time.current),
            comment_counter: 1,
            timezone: "Europe/Zurich"
          )
        )
      end

      def for_collaborator
        render(
          Collab::Annotations::CommentComponent.new(
            comment: Comment.create(
              message: "test",
              collaborator: Collaborator.new(name: "A collaborator"),
              created_at: Time.current
            ),
            comment_counter: 1,
            timezone: "Europe/Zurich"
          )
        )
      end
    end
  end
end
