# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Collab::Annotations::CommentFormComponent) do
  let(:annotation) { create(:annotation) }
  let(:component) { described_class.new(annotation: annotation, comment: comment) }

  context "when it's a new comment" do
    let(:comment) { Comment.new }

    it do
      render_inline(component)

      expect(page).to have_select("comment_template")
      expect(page).to have_css("textarea[name='comment[message]']", text: "")
      expect(page).to have_button(class: %w[btn btn-primary])
    end
  end

  context "when the comment has an error" do
    before do
      allow_any_instance_of(Comment).to receive(:message).and_return("This is a comment")
      allow_any_instance_of(Comment)
        .to receive(:errors)
        .and_return(ActiveModel::Errors.new(comment).tap { |e| e.add(:message, "is not valid") })
    end

    let(:comment) { create(:comment, :from_collaborator) }

    it do
      render_inline(component)

      expect(page).to have_select("comment_template")
      expect(page).to have_css("textarea[name='comment[message]']", text: "This is a comment")
      expect(page).to have_button(class: %w[btn btn-primary])
      expect(page).to have_css("p.text-red-600", text: "Message is not valid")
    end
  end
end
