# frozen_string_literal: true

require "rails_helper"

describe(Collab::Annotations::AnnotationItemsDestroyFormPolicy) do
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
  let!(:user_1_destroy_form) { Annotations::AnnotationItemsDestroyForm.new(annotation: user_1_annotation) }

  let!(:user_2) { create(:user) }
  let!(:user_2_participation) { create(:participation, cohort: cohort_2, user: user_2) }
  let!(:user_2_annotation) { create(:annotation, participation: user_2_participation) }
  let!(:user_2_destroy_form) { Annotations::AnnotationItemsDestroyForm.new(annotation: user_2_annotation) }

  let!(:user_3) { create(:user) }
  let!(:user_3_participation) { create(:participation, cohort: cohort_1, user: user_3, started_at: 2.days.ago, ended_at: Time.current) }
  let!(:user_3_annotation) { create(:annotation, participation: user_3_participation, intakes: build_list(:intake, 1, consumed_at: 1.minute.ago)) }
  let!(:user_3_destroy_form) { Annotations::AnnotationItemsDestroyForm.new(annotation: user_3_annotation) }

  let!(:user_4) { create(:user) }
  let!(:user_4_participation) { create(:participation, cohort: cohort_2, user: user_4, started_at: 2.days.ago, ended_at: Time.current) }
  let!(:user_4_annotation) { create(:annotation, participation: user_4_participation, intakes: build_list(:intake, 1, consumed_at: 1.minute.ago)) }
  let!(:user_4_destroy_form) { Annotations::AnnotationItemsDestroyForm.new(annotation: user_4_annotation) }

  permissions :destroy? do
    context "when admin" do
      it do
        expect(described_class).to permit(admin, user_1_destroy_form)
        expect(described_class).to permit(admin, user_2_destroy_form)
        expect(described_class).to permit(admin, user_3_destroy_form)
        expect(described_class).to permit(admin, user_4_destroy_form)
      end
    end

    context "when manager_1" do
      it do
        expect(described_class).to permit(manager_1, user_1_destroy_form)
        expect(described_class).not_to permit(manager_1, user_2_destroy_form)
        expect(described_class).to permit(manager_1, user_3_destroy_form)
        expect(described_class).not_to permit(manager_1, user_4_destroy_form)
      end
    end

    context "when manager_2" do
      it do
        expect(described_class).not_to permit(manager_2, user_1_destroy_form)
        expect(described_class).to permit(manager_2, user_2_destroy_form)
        expect(described_class).not_to permit(manager_2, user_3_destroy_form)
        expect(described_class).to permit(manager_2, user_4_destroy_form)
      end
    end

    context "when annotator_1" do
      it do
        expect(described_class).to permit(annotator_1, user_1_destroy_form)
        expect(described_class).not_to permit(annotator_1, user_2_destroy_form)
        expect(described_class).to permit(annotator_1, user_3_destroy_form)
        expect(described_class).not_to permit(annotator_1, user_4_destroy_form)
      end
    end

    context "when annotator_2" do
      it do
        expect(described_class).not_to permit(annotator_2, user_1_destroy_form)
        expect(described_class).to permit(annotator_2, user_2_destroy_form)
        expect(described_class).not_to permit(annotator_2, user_3_destroy_form)
        expect(described_class).to permit(annotator_2, user_4_destroy_form)
      end
    end
  end

  describe "#permitted_attributes" do
    it do
      expect(described_class.new(annotator_1, user_1_destroy_form).permitted_attributes)
        .to contain_exactly(annotation_item_ids: [])
      expect(described_class.new(admin, user_1_destroy_form).permitted_attributes)
        .to contain_exactly(annotation_item_ids: [])
    end
  end
end
