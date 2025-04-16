# frozen_string_literal: true

require "rails_helper"

describe(Foods::UpdateKcalMaxService) do
  let!(:cohort) { create(:cohort, :with_food_list) }
  let!(:participation) { create(:participation, cohort: cohort) }
  let!(:food_list) { cohort.food_lists.first }
  let!(:annotation) { create(:annotation, participation: participation) }
  let!(:food) { create(:food, kcal_max: 500, food_list: food_list, annotation_items: annotation_items) }
  let!(:nutrient_kcal) { create(:nutrient, id: "energy_kcal", unit: create(:unit, :energy)) }
  let(:service) { described_class.new }

  describe "#call" do
    let(:annotation_items) do
      build_list(
        :annotation_item, 4,
        annotation: annotation
      )
    end

    before { food.annotation_items.update_all(consumed_kcal: 50) }

    context "when no params are passed to #call" do
      before do
        food.annotation_items.update_all(updated_at: 2.days.ago)
      end

      it do
        allow(service).to receive(:all_foods).and_return(service.send(:all_foods))
        service.call
        expect(service).to have_received(:all_foods)
      end

      it "updates food.kcal_max but doesn't touch associated annotation_items" do
        expect { service.call }
          .to change { food.reload.kcal_max }.from(500).to(50)
          .and(not_change { annotation_items.first.reload.updated_at })
      end
    end

    context "when :datetime param is passed to #call" do
      let(:datetime) { 2.days.ago }

      it do
        allow(service).to receive(:last_annotated_foods_since).and_return(Food.none)
        service.call(datetime: datetime)
        expect(service).to have_received(:last_annotated_foods_since).with(datetime: datetime)
      end
    end
  end

  describe "private #all_foods" do
    let(:annotation_items) do
      build_list(
        :annotation_item, 3,
        annotation: annotation
      )
    end

    context "when food has only 3 dish foods" do
      it { expect(service.send(:all_foods)).to be_empty }
    end

    context "when food has 4 dish foods" do
      before do
        create(
          :annotation_item,
          food: food,
          annotation: annotation
        )
        food.annotation_items.update_all(updated_at: 2.days.ago, consumed_kcal: 33)
      end

      it { expect(service.send(:all_foods)).to contain_exactly(food) }
      it { expect(service.send(:all_foods).first.attributes.keys).to include("kcal_consumed_count", "kcal_consumed_z_score") }
    end

    context "when 1 aggregated_annotation_item has no energy_kcal_consumed" do
      before do
        food.annotation_items.update_all(updated_at: 2.days.ago, consumed_kcal: 33)

        create(
          :annotation_item,
          food: food,
          annotation: annotation,
          updated_at: 2.days.ago
        )
      end

      it { expect(service.send(:all_foods)).to be_empty }
    end
  end

  describe "private #last_annotated_foods_since(datetime:)" do
    context "when last_n_days = 1" do
      let(:datetime) { 2.days.ago }

      let(:annotation_items) do
        build_list(
          :annotation_item, 4,
          annotation: annotation
        )
      end

      before { food.annotation_items.update_all(consumed_kcal: 33) }

      context "when all dishfoods were updated during last day" do
        it { expect(service.send(:last_annotated_foods_since, datetime: datetime)).to contain_exactly(food) }
      end

      context "when dishfoods were last updated 2 days ago" do
        before do
          food.annotation_items.update_all(updated_at: 2.days.ago)
        end

        it { expect(service.send(:last_annotated_foods_since, datetime: datetime)).to be_empty }
      end
    end
  end
end
