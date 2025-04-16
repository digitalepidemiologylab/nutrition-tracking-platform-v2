# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Collab::DishPolicy) do
  let!(:admin) { create(:collaborator, :admin) }

  let!(:manager) { create(:collaborator) }
  let!(:manager_collaboration) { create(:collaboration, :manager, collaborator: manager) }
  let!(:manager_collaboration_cohort) { manager_collaboration.cohort }

  let!(:annotator) { create(:collaborator) }
  let!(:annotator_collaboration) { create(:collaboration, :annotator, collaborator: annotator) }
  let!(:annotator_collaboration_cohort) { annotator_collaboration.cohort }

  let!(:user_1) { create(:user) }
  let!(:user_1_participation_manager_collaboration_cohort) {
    create(:participation, user: user_1, cohort: manager_collaboration_cohort)
  }
  let!(:user_1_participation_annotator_collaboration_cohort) {
    create(:participation, user: user_1, cohort: annotator_collaboration_cohort)
  }
  let!(:user_1_dish) { create(:dish, user: user_1) }

  let!(:user_2) { create(:user) }
  let!(:user_2_participation_manager_collaboration_cohort) {
    create(:participation, user: user_2, cohort: manager_collaboration_cohort)
  }
  let!(:user_2_dish) { create(:dish, user: user_2) }

  let!(:user_3) { create(:user) }
  let!(:user_3_participation_annotator_collaboration_cohort) {
    create(:participation, user: user_3, cohort: annotator_collaboration_cohort)
  }
  let!(:user_3_dish) { create(:dish, user: user_3) }

  let!(:user_4) { create(:user) }
  let!(:user_4_dish) { create(:dish, user: user_4) }

  permissions :index? do
    it do
      expect(described_class).to permit(admin)
      expect(described_class).to permit(manager)
      expect(described_class).to permit(annotator)
    end
  end

  describe Collab::DishPolicy::Scope do
    describe "#resolve" do
      context "when admin" do
        it do
          expect(described_class.new(admin, Dish).resolve)
            .to contain_exactly(user_1_dish, user_2_dish, user_3_dish, user_4_dish)
        end
      end

      context "when manager" do
        it do
          expect(described_class.new(manager, Dish).resolve)
            .to contain_exactly(user_1_dish, user_2_dish)
        end
      end

      context "when annotator" do
        it do
          expect(described_class.new(annotator, Dish).resolve)
            .to contain_exactly(user_1_dish, user_3_dish)
        end
      end
    end
  end
end
