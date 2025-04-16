# frozen_string_literal: true

module Collab
  module Annotations
    class CommentFormComponent < ApplicationComponent
      include Turbo::FramesHelper

      def initialize(annotation:, comment:)
        @annotation = annotation
        @comment = comment
        @comment_templates = CommentTemplate.i18n.includes(:translations).order(:title)
      end
    end
  end
end
