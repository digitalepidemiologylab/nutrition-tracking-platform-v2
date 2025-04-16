# frozen_string_literal: true

require "rails_helper"

describe(IntakesQuery, :freeze_time) do
  let(:query) do
    described_class
      .new(initial_scope: Intake, policy: policy)
      .query(params: ActionController::Parameters.new(params))
  end
  let(:policy) { nil }
  let!(:dish) do
    dish = create(:dish)
    dish.annotations.sole.participation.update!(started_at: 3.days.ago, ended_at: 1.day.from_now)
    dish
  end
  let(:food_list) { create(:food_list) }
  let(:annotation) { dish.annotations.sole }
  let(:participation) { annotation.participation }
  let!(:intake_1) { annotation.intakes.sole }
  let!(:intake_2) { create(:intake, annotation: annotation, created_at: 2.days.ago, updated_at: 2.days.ago, consumed_at: 1.day.ago) }
  let!(:intake_3) { create(:intake, annotation: annotation, created_at: 1.day.ago, updated_at: 1.day.ago, consumed_at: 2.days.ago) }

  before do
    annotation.cohort.update!(food_lists: [food_list])
  end

  describe "without params" do
    let(:params) { {} }

    it { expect(query.to_a).to eq([intake_1, intake_3, intake_2]) }
  end

  describe "#filter_by_query(scoped, params)" do
    let(:params) { {query: query_string} }

    context "when query is empty" do
      let(:query_string) { "" }

      it { expect(query.to_a).to eq([intake_1, intake_3, intake_2]) }
    end

    context "when query is parsable as a date" do
      let(:query_string) { 2.days.ago.to_date.to_s }

      it { expect(query).to contain_exactly(intake_3) }
    end

    context "when query is a food name" do
      let(:food) { create(:food, food_list: food_list, name: "test") }
      let(:query_string) { food.name }

      context "when food is not in the annotation" do
        it { expect(query).to be_empty }
      end

      context "when food is in the annotation" do
        before do
          create(:annotation_item, annotation: annotation, food: food)
        end

        it { expect(query.to_a).to eq([intake_1, intake_3, intake_2]) }
      end
    end

    context "when query is a product barcode" do
      let(:product) { create(:product, barcode: "5449000000286") }
      let(:query_string) { product.barcode }

      context "when product is not in the annotation" do
        it { expect(query).to be_empty }
      end

      context "when product is in the annotation" do
        before do
          create(:annotation_item, annotation: annotation, product: product, food: nil)
        end

        it { expect(query.to_a).to eq([intake_1, intake_3, intake_2]) }
      end
    end

    context "when query is a product name" do
      let(:product) { create(:product, name: "cola") }
      let(:query_string) { "cola" }

      context "when product is not in the annotation" do
        it { expect(query).to be_empty }
      end

      context "when product is in the annotation" do
        before do
          create(:annotation_item, annotation: annotation, product: product, food: nil)
        end

        it { expect(query.to_a).to eq([intake_1, intake_3, intake_2]) }
      end
    end
  end

  describe "#filter_by_updated_at_gt" do
    context "with a correct date" do
      let(:params) { {filter: {updated_at_gt: (intake_2.updated_at + 1.minute).iso8601(6)}} }

      it { expect(query.to_a).to eq([intake_1, intake_3]) }
    end

    context "with a wrong date format" do
      let(:params) { {filter: {updated_at_gt: "test"}} }

      it { expect { query.to_a }.to raise_error(BaseQuery::BadFilterParam) }
    end
  end

  describe "#sorts(scoped, params)" do
    context "with no sort params" do
      let(:params) { {} }

      it { expect(query.to_a).to eq([intake_1, intake_3, intake_2]) }
    end

    context "with sort params" do
      let(:params) { {sort: "intakes.consumed_at", direction: "asc"} }

      context "when policy is nil" do
        it { expect(query.to_a).to eq([intake_2, intake_3, intake_1]) }
      end

      context "when policy is not nil" do
        context "when sort attribute is permitted" do
          let(:policy) { instance_double(Collab::IntakePolicy, permitted_sort_attributes: %w[intakes.consumed_at]) }

          it { expect(query.to_a).to eq([intake_3, intake_2, intake_1]) }
        end

        context "when sort attribute is not permitted" do
          let(:policy) { instance_double(Collab::IntakePolicy, permitted_sort_attributes: []) }

          it { expect(query.to_a).to eq([intake_2, intake_3, intake_1]) }
        end
      end
    end
  end
end
