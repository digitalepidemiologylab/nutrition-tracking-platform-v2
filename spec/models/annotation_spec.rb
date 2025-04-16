# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Annotation) do
  describe "Associations" do
    let(:annotation) { build(:annotation) }

    it do
      expect(annotation).to belong_to(:dish).inverse_of(:annotations)
      expect(annotation).to belong_to(:participation).inverse_of(:annotations)
      expect(annotation).to have_many(:intakes).inverse_of(:annotation).dependent(:destroy)
      expect(annotation).to have_one(:segmentation).inverse_of(:annotation).dependent(:destroy)
      expect(annotation).to have_many(:annotation_items).inverse_of(:annotation).dependent(:destroy)
      expect(annotation).to have_many(:products).through(:annotation_items)
      expect(annotation).to have_many(:comments).inverse_of(:annotation).dependent(:destroy)
    end
  end

  describe "Delegations" do
    let(:annotation) { build(:annotation) }

    it do
      expect(annotation).to delegate_method(:has_image?).to(:dish)
      expect(annotation).to delegate_method(:cohort).to(:participation)
      expect(annotation).to delegate_method(:food_lists).to(:cohort)
    end
  end

  describe "Status state machine" do
    let(:annotation) { build(:annotation, :with_dish_image) }

    describe "state" do
      it do
        expect(annotation).to have_state(:initial, :awaiting_segmentation_service, :annotatable, :info_asked,
          :annotated)
      end
    end

    describe "transitions" do
      it do
        expect(annotation)
          .to transition_from(:initial).to(:awaiting_segmentation_service).on_event(:send_to_segmentation_service)
      end

      it do
        expect(annotation)
          .to transition_from(:awaiting_segmentation_service)
          .to(:annotatable).on_event(:open_annotation)
      end

      it { expect(annotation).to transition_from(:annotatable).to(:annotated).on_event(:confirm) }

      it do
        food_set = create(:food_set)
        annotation.save!
        annotation_item = create(:annotation_item, annotation: annotation, food_set: food_set, original_food_set: food_set)

        annotation.send_to_segmentation_service!
        annotation.open_annotation!
        expect { annotation.confirm! }
          .to change { annotation_item.reload.food_set_id }.from(food_set.id).to(nil)
          .and(not_change { annotation_item.reload.original_food_set_id }.from(food_set.id))
      end

      it { expect(annotation).to transition_from(:annotatable).to(:info_asked).on_event(:ask_info) }

      it do
        expect(annotation).to transition_from(:initial).to(:annotatable).on_event(:open_annotation)
        expect(annotation).to transition_from(:awaiting_segmentation_service).to(:annotatable).on_event(:open_annotation)
        expect(annotation).to transition_from(:info_asked).to(:annotatable).on_event(:open_annotation)
        expect(annotation).to transition_from(:annotated).to(:annotatable).on_event(:open_annotation)
      end
    end

    describe "allowed events" do
      context "when status is initial" do
        it { expect(annotation).to allow_event(:send_to_segmentation_service, :open_annotation) }

        it do
          expect(annotation).not_to allow_event(:ask_info, :open_annotation, :confirm)
        end
      end

      context "when status is awaiting_segmentation_service" do
        before { annotation.send_to_segmentation_service }

        it { expect(annotation).to allow_event(:open_annotation) }

        it { expect(annotation).not_to allow_event(:send_to_segmentation_service, :ask_info, :open_annotation, :confirm) }
      end

      context "when status is annotatable" do
        before do
          annotation.send_to_segmentation_service
          annotation.open_annotation
        end

        it { expect(annotation).to allow_event(:confirm, :ask_info) }

        it do
          expect(annotation).not_to allow_event(
            :send_to_segmentation_service, :open_annotation
          )
        end
      end

      context "when status is asked_for_info" do
        before do
          annotation.send_to_segmentation_service
          annotation.open_annotation
          annotation.ask_info
        end

        it { expect(annotation).to allow_event(:open_annotation) }

        it do
          expect(annotation).not_to allow_event(
            :send_to_segmentation_service, :open_annotation, :ask_info, :confirm
          )
        end
      end

      context "when status is annotated" do
        before do
          annotation.send_to_segmentation_service
          annotation.open_annotation
          annotation.confirm
        end

        it do
          expect(annotation).to allow_event(:open_annotation)
          expect(annotation).not_to allow_event(
            :send_to_segmentation_service, :ask_info, :open_annotation, :confirm
          )
        end
      end
    end

    describe "after_all_transitions" do
      describe "#touch_intakes" do
        let!(:dish) { create(:dish, :with_dish_image) }
        let!(:annotation) { create(:annotation, dish: dish) }
        let!(:intake) { annotation.intakes.sole }

        it do
          expect { annotation.send_to_segmentation_service }.to change { intake.reload.updated_at }
        end
      end
    end
  end

  describe "Callbacks" do
    describe "after_create_commit" do
      describe "segment_or_open_annotation" do
        let(:annotation) { build(:annotation, dish: dish) }

        describe "when dish_image exists" do
          let(:dish) { create(:dish, :with_dish_image) }

          it do
            expect { annotation.save }.to have_enqueued_job(Annotations::CreateSegmentationJob)
              .on_queue("default")
              .with(annotation: annotation)
              .once
          end
        end

        describe "when dish_image doesn't exist" do
          let(:dish) { create(:dish) }

          it do
            expect { annotation.save }.not_to have_enqueued_job(Annotations::CreateSegmentationJob)
            expect(annotation).to be_annotatable
          end
        end
      end
    end

    describe "after_destroy_commit" do
      describe "destroy_dish_if_no_annotations" do
        context "when dish has no more annotation" do
          let!(:dish) { create(:dish, :with_annotation) }

          it do
            expect { dish.annotations.sole.destroy }
              .to change(Dish, :count).by(-1)
            expect(dish).to be_destroyed
          end
        end

        context "when dish has many annotations" do
          let!(:dish) { create(:dish, :with_annotations) }

          it do
            expect { dish.annotations.first.destroy }
              .to not_change(Dish, :count)
            expect(dish).not_to be_destroyed
            expect(dish.reload.annotations.count).to eq(1)
          end
        end
      end
    end
  end

  describe "#image" do
    let(:annotation) { create(:annotation, dish: dish, annotation_items: annotation_items) }

    describe "when dish_image exists" do
      let(:dish) { create(:dish, :with_dish_image) }
      let(:annotation_items) { [] }

      it { expect(annotation.image).to eq(dish.dish_image.data) }
    end

    describe "whithout dish_image" do
      let(:dish) { create(:dish) }

      describe "when product annotation_items exist" do
        let(:annotation_items) { [build(:annotation_item, food: nil, product: product)] }

        describe "when product has image_url" do
          let(:image_url) { "image_url" }
          let(:product) { create(:product, image_url: image_url, product_images: product_images) }

          context "without product_images" do
            let(:product_images) { [] }

            it { expect(annotation.image).to eq(image_url) }
          end

          context "with product_images" do
            let(:product_images) { [build(:product_image)] }

            it { expect(annotation.image).to eq(image_url) }
          end
        end

        describe "when product doesn't have image_url" do
          let(:product) { create(:product, image_url: nil, product_images: product_images) }

          context "without product_images" do
            let(:product_images) { [] }

            it { expect(annotation.image).to be_nil }
          end

          context "with product_images" do
            let(:product_images) { [build(:product_image)] }

            it { expect(annotation.image.record).to eq(product_images.first) }
          end
        end
      end
    end
  end

  describe "#total_consumed(unit: :g)" do
    let!(:annotation) {
      build(:annotation,
        annotation_items: [
          annotation_item_1,
          annotation_item_2,
          annotation_item_3,
          annotation_item_4,
          annotation_item_5,
          annotation_item_6,
          annotation_item_7
        ])
    }
    let(:annotation_item_1) do
      build(
        :annotation_item,
        present_quantity: 1, present_unit: create(:unit, :mass),
        consumed_quantity: 1, consumed_unit: create(:unit, :mass)
      )
    end
    let(:annotation_item_2) do
      build(
        :annotation_item,
        present_quantity: 2, present_unit: create(:unit, :volume),
        consumed_quantity: 1, consumed_unit: create(:unit, :volume)
      )
    end
    let(:annotation_item_3) do
      build(
        :annotation_item,
        present_quantity: 1, present_unit: create(:unit, :mass),
        consumed_quantity: nil, consumed_unit: create(:unit, :mass)
      )
    end
    let(:annotation_item_4) do
      build(
        :annotation_item,
        present_quantity: 1, present_unit: create(:unit, :mass),
        consumed_quantity: 1, consumed_unit: nil
      )
    end
    let(:annotation_item_5) do
      build(
        :annotation_item,
        present_quantity: nil, present_unit: create(:unit, :mass),
        consumed_quantity: 1, consumed_unit: create(:unit, :volume)
      )
    end
    let(:annotation_item_6) do
      build(
        :annotation_item,
        present_quantity: nil, present_unit: create(:unit, :mass),
        consumed_quantity: 1, consumed_unit: create(:unit, :volume)
      )
    end
    let(:annotation_item_7) do
      build(
        :annotation_item,
        present_quantity: 1, present_unit: create(:unit, :volume),
        consumed_quantity: nil, consumed_unit: nil
      )
    end

    it do
      expect(annotation.total_consumed(:d)).to eq(0)
      expect(annotation.total_consumed(:g)).to eq(2.01)
      expect(annotation.total_consumed(:ml)).to eq(4.0)
    end
  end

  describe "#total_kcal_consumed" do
    let!(:annotation) { create(:annotation, :with_annotation_items) }

    before do
      annotation.annotation_items.first.update_columns(consumed_kcal: 226)
    end

    it { expect(annotation.total_kcal_consumed).to eq(226.0) }
  end
end
