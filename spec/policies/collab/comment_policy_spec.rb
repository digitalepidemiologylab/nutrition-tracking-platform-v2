# frozen_string_literal: true

require "rails_helper"

describe(Collab::CommentPolicy) do
  let!(:cohort_1) { create(:cohort) }
  let!(:cohort_2) { create(:cohort) }

  let!(:admin) { create(:collaborator, :admin) }

  let!(:manager_1) { create(:collaborator) }
  let!(:manager_1_collaboration) { create(:collaboration, :manager, collaborator: manager_1, cohort: cohort_1) }

  let!(:manager_2) { create(:collaborator) }
  let!(:manager_2_collaboration) { create(:collaboration, :manager, collaborator: manager_2, cohort: cohort_2) }

  let!(:annotator_1) { create(:collaborator) }
  let!(:annotator_1_collaboration) { create(:collaboration, :annotator, collaborator: annotator_1, cohort: cohort_1) }

  let!(:annotator_2) { create(:collaborator) }
  let!(:annotator_2_collaboration) { create(:collaboration, :annotator, :deactivated, collaborator: annotator_2, cohort: cohort_2) }

  let!(:user_1) { create(:user) }
  let!(:user_1_participation) { create(:participation, cohort: cohort_1, user: user_1) }
  let!(:user_1_annotation) { create(:annotation, participation: user_1_participation) }
  let!(:user_1_comment) { create(:comment, user: user_1, annotation: user_1_annotation) }
  let!(:annotator_1_comment) { create(:comment, collaborator: annotator_1, user: nil, annotation: user_1_annotation) }

  let!(:user_2) { create(:user) }
  let!(:user_2_participation) { create(:participation, cohort: cohort_2, user: user_2) }
  let!(:user_2_annotation) { create(:annotation, participation: user_2_participation) }
  let!(:user_2_comment) { create(:comment, user: user_2, annotation: user_2_annotation) }

  let!(:user_3) { create(:user) }
  let!(:user_3_participation) { create(:participation, cohort: cohort_1, user: user_3) }
  let!(:user_3_annotation) { create(:annotation, :annotated, participation: user_3_participation) }
  let!(:user_3_comment) { create(:comment, user: user_3, annotation: user_3_annotation) }

  permissions :index? do
    it do
      expect(described_class).to permit(admin)
      expect(described_class).to permit(manager_1)
      expect(described_class).to permit(manager_2)
      expect(described_class).to permit(annotator_1)
      expect(described_class).to permit(annotator_2)
    end
  end

  permissions :create? do
    context "when the collaborator has access to the dish and is the owner of the comment" do
      it do
        expect(described_class).to permit(admin, build(:comment, :from_collaborator, annotation: user_1_annotation, collaborator: admin))
        expect(described_class)
          .to permit(manager_1, build(:comment, :from_collaborator, annotation: user_1_annotation, collaborator: manager_1))
        expect(described_class)
          .to permit(annotator_1, build(:comment, :from_collaborator, annotation: user_1_annotation, collaborator: annotator_1))
      end
    end

    context "when the collaborator comments for another collaborator" do
      it do
        expect(described_class).to permit(admin, build(:comment, :from_collaborator, annotation: user_1_annotation, collaborator: manager_1))
        expect(described_class)
          .to permit(manager_1, build(:comment, :from_collaborator, annotation: user_1_annotation, collaborator: annotator_1))
        expect(described_class)
          .to permit(annotator_1, build(:comment, :from_collaborator, annotation: user_1_annotation, collaborator: manager_1))
      end
    end

    context "when the collaborator comments on a non-accessible dish" do
      it do
        expect(described_class).to permit(admin, build(:comment, :from_collaborator, collaborator: admin))
        expect(described_class)
          .not_to permit(manager_1, build(:comment, :from_collaborator, collaborator: manager_1))
        expect(described_class)
          .not_to permit(annotator_1, build(:comment, :from_collaborator, collaborator: annotator_1))
      end
    end

    context "when the collaborator comments on an :annotated dish" do
      it do
        expect(described_class).not_to permit(admin, build(:comment, :from_collaborator, annotation: user_3_annotation, collaborator: manager_1))
        expect(described_class)
          .not_to permit(manager_1, build(:comment, :from_collaborator, annotation: user_3_annotation, collaborator: annotator_1))
        expect(described_class)
          .not_to permit(annotator_1, build(:comment, :from_collaborator, annotation: user_3_annotation, collaborator: manager_1))
      end
    end
  end

  describe "#permitted_attributes" do
    it do
      expect(described_class.new(admin, user_1_comment).permitted_attributes)
        .to contain_exactly(:message, :silent)
    end
  end

  describe Collab::CommentPolicy::Scope do
    describe "#resolve" do
      context "when admin" do
        it do
          expect(described_class.new(admin, Comment).resolve)
            .to contain_exactly(user_1_comment, user_2_comment, user_3_comment, annotator_1_comment)
        end
      end

      context "when manager" do
        it do
          expect(described_class.new(manager_1, Comment).resolve)
            .to contain_exactly(user_1_comment, user_3_comment, annotator_1_comment)
          expect(described_class.new(manager_2, Comment).resolve)
            .to contain_exactly(user_2_comment)
        end
      end

      context "when annotator" do
        it do
          expect(described_class.new(annotator_1, Comment).resolve)
            .to contain_exactly(user_1_comment, user_3_comment, annotator_1_comment)
          expect(described_class.new(annotator_2, Comment).resolve)
            .to be_empty
        end
      end
    end
  end
end
