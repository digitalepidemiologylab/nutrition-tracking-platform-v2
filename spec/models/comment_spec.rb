# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Comment) do
  describe "Associations" do
    let(:comment) { build(:comment) }

    it do
      expect(comment).to belong_to(:annotation).inverse_of(:comments)
      expect(comment).to have_many(:push_notifications).inverse_of(:comment).dependent(:destroy)
    end

    context "when associated with user" do
      it { expect(comment).to belong_to(:collaborator).inverse_of(:comments).optional }
    end

    context "when associated with collaborator" do
      let(:comment) { build(:comment, :from_collaborator) }

      it { expect(comment).to belong_to(:user).inverse_of(:comments).optional }
    end
  end

  describe "Delegations" do
    let(:comment) { build(:comment) }

    describe "dish" do
      it { expect(comment).to delegate_method(:dish).to(:annotation) }
    end
  end

  describe "Validations" do
    let(:comment) { build(:comment) }

    describe "message" do
      it { expect(comment).to validate_presence_of(:message) }
    end

    describe "user and/or collaborator" do
      context "when associated with user" do
        it { expect(comment).to be_valid }
      end

      context "when associated with collaborator" do
        let(:comment) { build(:comment, :from_collaborator) }

        it { expect(comment).to be_valid }
      end

      context "when associated with user and collaborator" do
        let(:comment) { build(:comment, collaborator: build(:collaborator)) }

        it do
          expect(comment).not_to be_valid
          expect(comment.errors[:collaborator]).to contain_exactly("must be blank")
          expect(comment.errors[:user]).to contain_exactly("must be blank")
        end
      end

      context "when associated without user or collaborator" do
        let(:comment) { build(:comment, user: nil, collaborator: nil) }

        it do
          expect(comment).not_to be_valid
          expect(comment.errors[:collaborator]).to contain_exactly("can't be blank")
          expect(comment.errors[:user]).to contain_exactly("can't be blank")
        end
      end
    end
  end

  describe "Callbacks" do
    describe "after_commit" do
      describe "#touch_intakes" do
        let!(:dish) { create(:dish) }
        let!(:annotation) { create(:annotation, dish: dish) }
        let!(:intake) { create(:intake, annotation: annotation) }
        let!(:other_intake) { create(:intake) }
        let(:comment) { build(:comment, annotation: annotation) }

        it do
          expect { comment.save }
            .to change { intake.reload.updated_at }
            .and(not_change { other_intake.reload.updated_at })
        end
      end
    end
  end

  describe "#broadcast(view_context:)" do
    let(:annotation) { create(:annotation) }
    let(:comment) { create(:comment, annotation: annotation) }
    let(:view_context) { nil }
    let(:comment_component) { instance_double(Collab::Annotations::CommentComponent) }

    before do
      allow(Collab::Annotations::CommentComponent).to receive(:new).and_return(comment_component)
      allow(comment_component).to receive(:render_in).and_return("rendered comment")
      allow(comment).to receive(:broadcast_append_to)
    end

    it do
      comment.broadcast(view_context: view_context)
      expect(comment).to have_received(:broadcast_append_to).with([annotation, :comments], html: "rendered comment", target: "comments_annotation_#{annotation.id}")
    end
  end
end
