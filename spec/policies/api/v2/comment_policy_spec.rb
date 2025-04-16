# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Api::V2::CommentPolicy) do
  let(:user) { create(:user) }

  permissions :index? do
    it { expect(described_class).to permit(user, Comment) }
  end

  permissions :create? do
    let(:annotation) { create(:annotation, dish: build(:dish, user: user)) }
    let!(:comment) { create(:comment, annotation: annotation) }
    let!(:other_user_comment) { create(:comment) }

    it do
      expect(described_class).to permit(user, comment)
      expect(described_class).not_to permit(user, other_user_comment)
    end
  end

  describe "#permitted_attributes" do
    let(:comment) { build(:comment) }

    it do
      expect(described_class.new(user, comment).permitted_attributes)
        .to contain_exactly(:id, :type, attributes: %i[message])
    end
  end

  describe "#permitted_includes" do
    let(:comment) { build(:comment) }

    it do
      expect(described_class.new(user, comment).permitted_includes).to contain_exactly("annotation")
    end
  end

  describe Api::V2::CommentPolicy::Scope do
    let(:annotation) { create(:annotation, dish: build(:dish, user: user)) }
    let!(:comment_1) { create(:comment, annotation: annotation) }
    let!(:comment_2) { create(:comment, annotation: annotation) }

    describe "#resolve" do
      context "when user has comments" do
        it { expect(described_class.new(user, Comment).resolve).to contain_exactly(comment_1, comment_2) }
      end

      context "when user has no comments" do
        let(:user_without_comment) { create(:user) }

        it { expect(described_class.new(user_without_comment, Comment).resolve).to be_empty }
      end
    end
  end
end
