# frozen_string_literal: true

require "rails_helper"

describe(AnnotationItems::CalculateKcalService) do
  let!(:cohort) { create(:cohort, :with_food_list) }
  let!(:participation) { create(:participation, cohort: cohort) }
  let!(:food_list) { cohort.food_lists.first }
  let!(:annotation) { create(:annotation, participation: participation) }
  let!(:annotation_item) do
    create(
      :annotation_item,
      annotation: annotation,
      food: food,
      product: product,
      present_quantity: present_quantity,
      present_unit: present_unit,
      consumed_quantity: consumed_quantity,
      consumed_unit: consumed_unit
    )
  end
  let!(:nutrient) { create(:nutrient, id: "energy_kcal", unit: create(:unit, :energy)) }

  context "when food is present" do
    let(:food) {
      create(:food, food_list: food_list, unit: create(:unit, :mass))
    }
    let(:product) { nil }

    context "when present quantity and unit are present" do
      let(:present_quantity) { 100 }
      let(:present_unit) { create(:unit, :volume) }

      context "when consumed quantity and unit are present" do
        let(:consumed_quantity) { 50 }
        let(:consumed_unit) { create(:unit, :mass) }

        context "when food has kcal nutrient" do
          let!(:food_nutrient) { create(:food_nutrient, food: food, nutrient: nutrient, per_hundred: 100) }

          it { expect(described_class.new(annotation_item: annotation_item).call).to eq(50) }
        end

        context "when food has no kcal nutrient" do
          it { expect(described_class.new(annotation_item: annotation_item).call).to be_nil }
        end
      end

      context "when consumed quantity and unit are not present" do
        let(:consumed_quantity) { nil }
        let(:consumed_unit) { nil }

        context "when food has kcal nutrient" do
          let!(:food_nutrient) { create(:food_nutrient, food: food, nutrient: nutrient, per_hundred: 100) }

          it { expect(described_class.new(annotation_item: annotation_item).call).to eq(100) }
        end

        context "when food has no kcal nutrient" do
          it { expect(described_class.new(annotation_item: annotation_item).call).to be_nil }
        end
      end
    end

    context "when present quantity and unit are not present" do
      let(:present_quantity) { nil }
      let(:present_unit) { nil }

      context "when consumed quantity and unit are present" do
        let(:consumed_quantity) { 50 }
        let(:consumed_unit) { create(:unit, :mass) }

        context "when food has kcal nutrient" do
          let!(:food_nutrient) { create(:food_nutrient, food: food, nutrient: nutrient, per_hundred: 100) }

          it { expect(described_class.new(annotation_item: annotation_item).call).to eq(50) }
        end

        context "when food has no kcal nutrient" do
          it { expect(described_class.new(annotation_item: annotation_item).call).to be_nil }
        end
      end

      context "when consumed quantity and unit are not present" do
        let(:consumed_quantity) { nil }
        let(:consumed_unit) { nil }

        context "when food has kcal nutrient" do
          let!(:food_nutrient) { create(:food_nutrient, food: food, nutrient: nutrient, per_hundred: 100) }

          it { expect(described_class.new(annotation_item: annotation_item).call).to be_nil }
        end

        context "when food has no kcal nutrient" do
          it { expect(described_class.new(annotation_item: annotation_item).call).to be_nil }
        end
      end
    end
  end

  context "when product is present" do
    let(:product) { create(:product, unit: create(:unit, :mass)) }
    let(:food) { nil }

    context "when present quantity and unit are present" do
      let(:present_quantity) { 100 }
      let(:present_unit) { create(:unit, :volume) }

      context "when consumed quantity and unit are present" do
        let(:consumed_quantity) { 50 }
        let(:consumed_unit) { create(:unit, :mass) }

        context "when food has kcal nutrient" do
          let!(:product_nutrient) { create(:product_nutrient, product: product, nutrient: nutrient, per_hundred: 100) }

          it { expect(described_class.new(annotation_item: annotation_item).call).to eq(50) }
        end

        context "when product has no kcal nutrient" do
          it { expect(described_class.new(annotation_item: annotation_item).call).to be_nil }
        end
      end

      context "when consumed quantity and unit are not present" do
        let(:consumed_quantity) { nil }
        let(:consumed_unit) { nil }

        context "when product has kcal nutrient" do
          let!(:product_nutrient) { create(:product_nutrient, product: product, nutrient: nutrient, per_hundred: 100) }

          it { expect(described_class.new(annotation_item: annotation_item).call).to eq(100) }
        end

        context "when product has no kcal nutrient" do
          it { expect(described_class.new(annotation_item: annotation_item).call).to be_nil }
        end
      end
    end

    context "when present quantity and unit are not present" do
      let(:present_quantity) { nil }
      let(:present_unit) { nil }

      context "when consumed quantity and unit are present" do
        let(:consumed_quantity) { 50 }
        let(:consumed_unit) { create(:unit, :mass) }

        context "when product has kcal nutrient" do
          let!(:product_nutrient) { create(:product_nutrient, product: product, nutrient: nutrient, per_hundred: 100) }

          it { expect(described_class.new(annotation_item: annotation_item).call).to eq(50) }
        end

        context "when product has no kcal nutrient" do
          it { expect(described_class.new(annotation_item: annotation_item).call).to be_nil }
        end
      end

      context "when consumed quantity and unit are not present" do
        let(:consumed_quantity) { nil }
        let(:consumed_unit) { nil }

        context "when product has kcal nutrient" do
          let!(:product_nutrient) { create(:product_nutrient, product: product, nutrient: nutrient, per_hundred: 100) }

          it { expect(described_class.new(annotation_item: annotation_item).call).to be_nil }
        end

        context "when product has no kcal nutrient" do
          it { expect(described_class.new(annotation_item: annotation_item).call).to be_nil }
        end
      end
    end
  end
end
