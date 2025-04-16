# frozen_string_literal: true

require "rails_helper"

RSpec.describe(KcalInRangeValidator) do
  let(:dish) { build(:dish) }
  let(:annotation) { build(:annotation, dish: dish) }
  let(:food) { build(:food, kcal_min: kcal_min, kcal_max: kcal_max) }
  let(:annotation_item) { build(:annotation_item, annotation: annotation, food: food, disable_kcal_in_range_validation: disable_kcal_in_range_validation) }

  context "when food is missing kcal_max" do
    let(:kcal_min) { 10 }
    let(:kcal_max) { nil }
    let(:disable_kcal_in_range_validation) { false }

    context "when annotation_item.consumed_kcal is in range" do
      before do
        allow(annotation_item).to receive(:consumed_kcal).and_return(50.0)
      end

      it { expect(annotation_item).to be_valid }
    end

    context "when annotation_item.consumed_kcal is smaller than kcal_min" do
      before do
        allow(annotation_item).to receive(:consumed_kcal).and_return(5.0)
      end

      it do
        expect(annotation_item).not_to be_valid
        expect(annotation_item.errors.full_messages).to contain_exactly("Consumed kcal value out of limits:")
      end
    end
  end

  context "when food has both energy limits" do
    let(:kcal_min) { 10 }
    let(:kcal_max) { 100 }

    context "when annotation_item.consumed_kcal is in range" do
      before { allow(annotation_item).to receive(:consumed_kcal).and_return(50.0) }

      # when validation should not be performed
      context "when annotation_item.disable_kcal_in_range_validation is true" do
        let(:disable_kcal_in_range_validation) { true }

        it { expect(annotation_item).to be_valid }
      end

      # when validation should be performed
      context "when annotation_item.disable_kcal_in_range_validation is false" do
        let(:disable_kcal_in_range_validation) { false }

        it { expect(annotation_item).to be_valid }
      end
    end

    context "when annotation_item.consumed_kcal is lower than food.kcal_min" do
      before { allow(annotation_item).to receive(:consumed_kcal).and_return(5.0) }

      # when validation should not be performed
      context "when annotation_item.disable_kcal_in_range_validation is true" do
        let(:disable_kcal_in_range_validation) { true }

        it { expect(annotation_item).to be_valid }
      end

      # when validation should be performed
      context "when annotation_item.disable_kcal_in_range_validation is false" do
        let(:disable_kcal_in_range_validation) { false }

        it do
          expect(annotation_item).not_to be_valid
          expect(annotation_item.errors.full_messages).to contain_exactly("Consumed kcal value out of limits:")
        end
      end
    end

    context "when annotation_item.consumed_kcal is higher than food.kcal_max" do
      before { allow(annotation_item).to receive(:consumed_kcal).and_return(150.0) }

      # when validation should not be performed
      context "when annotation_item.disable_kcal_in_range_validation is true" do
        let(:disable_kcal_in_range_validation) { true }

        it { expect(annotation_item).to be_valid }
      end

      # when validation should be performed
      context "when annotation_item.disable_kcal_in_range_validation is false" do
        let(:disable_kcal_in_range_validation) { false }

        it do
          expect(annotation_item).not_to be_valid
          expect(annotation_item.errors.full_messages).to contain_exactly("Consumed kcal value out of limits:")
        end
      end
    end
  end
end
