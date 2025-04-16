# frozen_string_literal: true

module Collab
  module Annotations
    class CommentFormComponentPreview < ViewComponent::Preview
      def default
        render(
          Collab::Annotations::CommentFormComponent.new(annotation: Annotation.new(id: SecureRandom.uuid), comment: Comment.new)
        )
      end
    end
  end
end
