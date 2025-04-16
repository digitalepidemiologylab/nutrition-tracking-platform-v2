# frozen_string_literal: true

require "rails_helper"

RSpec.describe(AnnotationItem) do
  describe "Associations" do
    let(:annotation_item) { build(:annotation_item) }

    it do
      expect(annotation_item).to have_one(:polygon_set).inverse_of(:annotation_item).dependent(:destroy)
      expect(annotation_item).to belong_to(:annotation).inverse_of(:annotation_items)
      expect(annotation_item).to belong_to(:product).inverse_of(:annotation_items).optional
      expect(annotation_item).to belong_to(:food).inverse_of(:annotation_items).optional
      expect(annotation_item).to belong_to(:food_set).inverse_of(:annotation_items).optional
      expect(annotation_item).to belong_to(:original_food_set).optional
    end
  end

  describe "Validations" do
    let(:annotation_item) { build(:annotation_item) }

    it { expect(annotation_item).to be_valid }

    describe "#present_unit_id" do
      describe "presence" do
        context "when present_quantity is null" do
          let(:annotation_item) { build(:annotation_item, present_quantity: nil, present_unit: nil) }

          it { expect(annotation_item).to be_valid }
        end

        context "when present_quantity is not null" do
          let(:annotation_item) { build(:annotation_item, present_quantity: 40, present_unit: nil) }

          it do
            expect(annotation_item).not_to be_valid
            expect(annotation_item.errors.full_messages).to contain_exactly("Present unit can't be blank")
          end
        end
      end
    end

    describe "#consumed_unit_id" do
      describe "presence" do
        context "when consumed_quantity is null" do
          let(:annotation_item) { build(:annotation_item, consumed_quantity: nil, consumed_unit: nil) }

          it { expect(annotation_item).to be_valid }
        end

        context "when consumed_quantity is not null" do
          let(:annotation_item) { build(:annotation_item, consumed_quantity: 40, consumed_unit: nil) }

          it do
            expect(annotation_item).not_to be_valid
            expect(annotation_item.errors.full_messages).to contain_exactly("Consumed unit can't be blank")
          end
        end
      end
    end

    describe "#product_id" do
      let(:dish) { build(:dish) }
      let(:annotation) { dish.annotations.sole }
      let!(:annotation_item) { build(:annotation_item, annotation: annotation, food: food, product: product) }

      context "when food and product are nil" do
        let(:food) { nil }
        let(:product) { nil }

        it do
          expect(annotation_item).not_to be_valid
          expect(annotation_item.errors.full_messages).to contain_exactly("Barcode can't be blank")
        end
      end

      context "when food is set and product is nil" do
        let(:food) { build(:food) }
        let(:product) { nil }

        it { expect(annotation_item).to be_valid }
      end

      context "when food is nil and product is set" do
        let(:food) { nil }
        let(:product) { build(:product) }

        it { expect(annotation_item).to be_valid }
      end
    end

    describe "#food_must_be_from_same_food_lists_as_cohort" do
      let!(:cohort) { create(:cohort, :with_food_list) }
      let!(:food_list) { cohort.food_lists.first }
      let!(:participation) { create(:participation, cohort: cohort) }
      let!(:annotation) { create(:annotation, participation: participation) }
      let!(:annotation_item) { build(:annotation_item, food: food, annotation: annotation) }

      describe "when food is nil" do
        let(:food) { nil }

        it do
          expect(annotation_item).not_to be_valid
          expect(annotation_item.errors.full_messages).to contain_exactly("Barcode can't be blank")
        end
      end

      describe "when food belongs to cohort food list" do
        let(:food) { create(:food, food_list: food_list) }

        it { expect(annotation_item).to be_valid }
      end

      describe "when food does not belong to cohort food list" do
        let(:food) { create(:food) }

        it do
          expect(annotation_item).not_to be_valid
          expect(annotation_item.errors.full_messages).to contain_exactly("Food belongs to an invalid food list")
        end
      end
    end
  end

  describe "Callbacks" do
    describe "before_validation" do
      describe "calculate_consumed_percent" do
        let(:annotation_item) do
          build(
            :annotation_item,
            consumed_percent: consumed_percent,
            present_quantity: present_quantity,
            present_unit: create(:unit, :mass),
            consumed_quantity: 50,
            consumed_unit_id: consumed_unit_id
          )
        end

        before { annotation_item.validate }

        context "when consumed_unit = %" do
          let!(:consumed_unit_id) { "%" }

          context "when consumed_percent and present_quantity are not nil" do
            let(:consumed_percent) { 50 }
            let(:present_quantity) { 220 }

            it do
              expect(annotation_item.consumed_quantity).to eq(110.0)
              expect(annotation_item.consumed_unit_id).to eq("g")
            end
          end

          context "when consumed_percent and present_quantity are nil" do
            let(:consumed_percent) { nil }
            let(:present_quantity) { 80 }

            it do
              expect(annotation_item.consumed_quantity).to eq(40)
              expect(annotation_item.consumed_unit_id).to eq("g")
            end
          end
        end

        context "when consumed_unit != %" do
          let!(:consumed_unit_id) { "ml" }
          let(:consumed_percent) { nil }
          let(:present_quantity) { 80 }

          it do
            expect(annotation_item.consumed_quantity).to eq(50)
            expect(annotation_item.consumed_unit_id).to eq("ml")
          end
        end
      end

      describe "set_consumed_kcal" do
        let!(:annotation_item) { build(:annotation_item) }
        let!(:service) { instance_double(AnnotationItems::CalculateKcalService) }

        before do
          allow(service).to receive(:call).and_return(333)
          allow(AnnotationItems::CalculateKcalService).to receive(:new).and_return(service)
        end

        it do
          expect { annotation_item.validate }
            .to change(annotation_item, :consumed_kcal).from(nil).to(333)
          expect(AnnotationItems::CalculateKcalService).to have_received(:new).with(annotation_item: annotation_item).at_least(:once)
          expect(service).to have_received(:call).with(no_args).at_least(:once)
        end
      end

      describe "set_color_index" do
        let!(:annotation) { build(:annotation, :with_annotation_items) }
        let!(:annotation_item_1) { annotation.annotation_items.first }
        let!(:annotation_item_2) { annotation.annotation_items.last }

        it do
          expect { annotation_item_1.valid? }
            .to change(annotation_item_1, :color_index).from(nil).to(0)
            .and not_change(annotation_item_2, :color_index).from(nil)
          expect { annotation_item_1.save! }
            .to not_change(annotation_item_1, :color_index).from(0)
            .and change(annotation_item_2, :color_index).from(nil).to(1)
        end
      end
    end
  end

  describe "Delegations" do
    let(:annotation_item) { build(:annotation_item) }

    it do
      expect(annotation_item).to delegate_method(:polygons).to(:polygon_set).allow_nil
      expect(annotation_item).to delegate_method(:ml_confidence).to(:polygon_set).allow_nil
      delegate_method(:barcode).to(:product).allow_nil
    end
  end

  describe "#item=(item) and #item" do
    let(:annotation_item) { build(:annotation_item, item: item) }

    context "when item is a Food" do
      let(:item) { build(:food) }

      it do
        expect(annotation_item.food).to eq(item)
        expect(annotation_item.product).to be_nil
        expect(annotation_item.item).to eq(item)
      end
    end

    context "when item is a Product" do
      let(:item) { build(:product) }

      it do
        expect(annotation_item.food).to be_nil
        expect(annotation_item.product).to eq(item)
        expect(annotation_item.item).to eq(item)
      end
    end

    context "when item is another object" do
      let(:item) { "a string!" }

      it do
        expect { build(:annotation_item, item: item) }
          .to raise_error(ArgumentError, "Item must be a Food or a Product")
      end
    end
  end

  describe "#barcode=(barcode) and #barcode" do
    let(:annotation_item) { build(:annotation_item, food: nil, product: nil, barcode: barcode) }

    context "when product exists" do
      let!(:product) { create(:product) }
      let(:barcode) { product.barcode }

      it do
        expect { annotation_item }.not_to change(Product, :count)
        expect(annotation_item.product).to eq(product)
        expect(annotation_item.barcode).to eq(barcode)
      end
    end

    context "when product doesn't exist" do
      context "when barcode is valid" do
        let(:barcode) { "0836359009889" }

        it do
          expect { annotation_item }.to change(Product, :count).by(1)
          expect(annotation_item.product).to eq(Product.last)
          expect(annotation_item.barcode).to eq(barcode)
        end
      end

      context "when barcode is invalid" do
        let(:barcode) { "invalid" }

        it do
          expect { annotation_item }.not_to change(Product, :count)
          expect(annotation_item.barcode).to eq(barcode)
          expect(annotation_item.errors)
            .to contain_exactly("Barcode Validation failed: Barcode can't be blank,
              Barcode must be a valid EAN or UPC barcode".squish)
        end
      end
    end
  end

  describe "#calculated_consumed_quantity" do
    let(:annotation_item_1) do
      build(:annotation_item,
        present_quantity: 1, present_unit: create(:unit, :mass),
        consumed_quantity: 1, consumed_unit: create(:unit, :mass))
    end
    let(:annotation_item_2) do
      build(:annotation_item,
        present_quantity: 2, present_unit: create(:unit, :volume),
        consumed_quantity: 1, consumed_unit: create(:unit, :volume))
    end
    let(:annotation_item_3) do
      build(:annotation_item,
        present_quantity: 1, present_unit: create(:unit, :mass),
        consumed_quantity: nil, consumed_unit: create(:unit, :mass))
    end
    let(:annotation_item_4) do
      build(:annotation_item,
        present_quantity: 1, present_unit: create(:unit, :mass),
        consumed_quantity: 1, consumed_unit: nil)
    end
    let(:annotation_item_5) do
      build(:annotation_item,
        present_quantity: nil, present_unit: create(:unit, :mass),
        consumed_quantity: 1, consumed_unit: create(:unit, :volume))
    end
    let(:annotation_item_6) do
      build(:annotation_item,
        present_quantity: nil, present_unit: create(:unit, :mass),
        consumed_quantity: 1, consumed_unit: create(:unit, :volume))
    end
    let(:annotation_item_7) do
      build(:annotation_item,
        present_quantity: 1, present_unit: create(:unit, :mass),
        consumed_quantity: nil, consumed_unit: nil)
    end

    it do
      expect(annotation_item_1.calculated_consumed_quantity).to eq(1.0)
      expect(annotation_item_2.calculated_consumed_quantity).to eq(1.0)
      expect(annotation_item_3.calculated_consumed_quantity).to eq(1.0)
      expect(annotation_item_4.calculated_consumed_quantity).to eq(0.01)
      expect(annotation_item_5.calculated_consumed_quantity).to eq(1.0)
      expect(annotation_item_6.calculated_consumed_quantity).to eq(1.0)
      expect(annotation_item_7.calculated_consumed_quantity).to eq(1.0)
    end
  end

  describe "#in_unit?(unit_id)" do
    let(:annotation_item_1) do
      build(:annotation_item,
        present_quantity: 1, present_unit: create(:unit, :mass),
        consumed_quantity: 1, consumed_unit: create(:unit, :mass))
    end
    let(:annotation_item_2) do
      build(:annotation_item,
        present_quantity: 1, present_unit: create(:unit, :mass),
        consumed_quantity: 1, consumed_unit: nil)
    end
    let(:annotation_item_3) do
      build(:annotation_item,
        present_quantity: 1, present_unit: create(:unit, :volume),
        consumed_quantity: 1, consumed_unit: nil)
    end
    let(:annotation_item_4) do
      build(:annotation_item,
        present_quantity: 1, present_unit: nil,
        consumed_quantity: 1, consumed_unit: nil)
    end

    it do
      expect(annotation_item_1).to be_in_unit("g")
      expect(annotation_item_2).to be_in_unit("g")
      expect(annotation_item_3).to be_in_unit("ml")
      expect(annotation_item_4).not_to be_in_unit("g")
      expect(annotation_item_4).not_to be_in_unit("ml")
    end
  end

  describe "#polygons=(polygons)" do
    let!(:cohort) { create(:cohort, :with_food_list) }
    let!(:food_list) { cohort.food_lists.first }
    let!(:participation) { create(:participation, cohort: cohort) }
    let!(:annotation) { create(:annotation, :with_dish_image, participation: participation) }
    let!(:food) { create(:food, food_list: food_list) }

    let(:polygons) {
      [
        [
          [0.474453, 0.27633],
          [0.41293, 0.279458],
          [0.653806, 0.450469],
          [0.672576, 0.388947],
          [0.676747, 0.347237],
          [0.657977, 0.300313],
          [0.631908, 0.277372]
        ]
      ].to_json
    }

    context "when annotation_item had no previous polygon_sets" do
      let!(:annotation_item) do
        create(:annotation_item, annotation: annotation)
      end

      it do
        expect { annotation_item.update(polygons: polygons) }
          .to change(PolygonSet, :count).by(1)
      end
    end

    context "when annotation_item had previous polygon_sets" do
      let!(:annotation_item) do
        create(:annotation_item, :with_polygon_set,
          annotation: annotation)
      end

      context "when polygons is not blank" do
        it do
          expect { annotation_item.update(polygons: polygons) }
            .to not_change(PolygonSet, :count)
            .and(change { annotation_item.polygon_set.polygons })
        end
      end

      context "when polygons is blank" do
        it do
          expect { annotation_item.update(polygons: "") }
            .to change(PolygonSet, :count).by(-1)
        end
      end
    end
  end

  describe "#color_index" do
    let!(:annotation) { create(:annotation, annotation_items: build_list(:annotation_item, 12, :with_product)) }
    let(:annotation_item_1) { annotation.annotation_items.first }
    let(:annotation_item_2) { annotation.annotation_items.second }
    let(:annotation_item_3) { annotation.annotation_items.third }
    let(:annotation_item_10) { annotation.annotation_items[9] }
    let(:annotation_item_11) { annotation.annotation_items[10] }
    let(:annotation_item_12) { annotation.annotation_items[11] }

    it do
      expect(annotation_item_1.color_index).to eq(0)
      expect(annotation_item_2.color_index).to eq(1)
      expect(annotation_item_3.color_index).to eq(2)
      expect(annotation_item_10.color_index).to eq(9)
      expect(annotation_item_11.color_index).to eq(0)
      expect(annotation_item_12.color_index).to eq(1)
    end
  end
end
