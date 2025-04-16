# frozen_string_literal: true

require "rails_helper"

describe(CommentTemplate) do
  describe "Translation" do
    let(:comment_template) { build(:comment_template, :with_title, :with_message) }

    it { expect(comment_template).to translate(:title) }
    it { expect(comment_template).to translate(:message) }
  end

  describe "Validations" do
    let(:comment_template) { build(:comment_template) }

    it do
      expect(comment_template).to validate_presence_of(:title)
      expect(comment_template).to validate_presence_of(:message)
    end
  end
end
