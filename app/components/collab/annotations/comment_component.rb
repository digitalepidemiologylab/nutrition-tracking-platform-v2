# frozen_string_literal: true

module Collab
  module Annotations
    class CommentComponent < ApplicationComponent
      def initialize(comment:, timezone:, comment_counter:, highlight: false)
        @comment = comment
        @timezone = timezone
        @counter = comment_counter
        @highlight = highlight
      end
    end
  end
end
