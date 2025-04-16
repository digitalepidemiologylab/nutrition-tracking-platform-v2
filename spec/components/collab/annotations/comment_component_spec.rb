# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Collab::Annotations::CommentComponent) do
  before { allow_any_instance_of(Comment).to receive(:message).and_return("This is a comment") }

  context "when the comment is from a user" do
    let(:comment) { create(:comment) }
    let(:component) { described_class.new(comment: comment, comment_counter: 1, timezone: "Europe/Zurich") }

    it do
      render_inline(component)

      expect(page).to have_text("This is a comment")
      expect(page).not_to have_css("div.border-t.border-gray-200")
      expect(page).to have_text("User")
      expect(page).to have_css(".rounded-full.bg-gray-100")
    end
  end

  context "when the comment is from a collaborator" do
    let(:comment) { create(:comment, :from_collaborator) }
    let(:component) { described_class.new(comment: comment, comment_counter: 1, timezone: "Europe/Zurich") }

    it do
      render_inline(component)

      expect(page).to have_text("This is a comment")
      expect(page).not_to have_css("div.border-t.border-gray-200")
      expect(page).to have_text(comment.collaborator.name)
      expect(page).to have_css(".rounded-full.bg-brand-lightest")
    end
  end

  context "when it's not the first comment" do
    let(:comment) { create(:comment) }
    let(:component) { described_class.new(comment: comment, comment_counter: 2, timezone: "Europe/Zurich") }

    it do
      render_inline(component)

      expect(page).to have_css("div.border-t.border-gray-200")
    end
  end
end
