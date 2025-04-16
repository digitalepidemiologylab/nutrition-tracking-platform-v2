# frozen_string_literal: true

require "rails_helper"

describe(Annotations::AnnotationItemsMergeForm) do
  let!(:cohort) { create(:cohort, :with_food_list) }
  let!(:participation) { create(:participation, cohort: cohort) }
  let!(:annotation) { create(:annotation, participation: participation) }

  let!(:annotation_item_1) { create(:annotation_item, :with_polygon_set, annotation: annotation, present_quantity: 1, consumed_quantity: 2, position: 1) }
  let!(:annotation_item_2) { create(:annotation_item, :with_polygon_set, annotation: annotation, present_quantity: 3, consumed_quantity: 4, position: 2) }
  let!(:annotation_item_3) { create(:annotation_item, :with_polygon_set, annotation: annotation, present_quantity: 5, consumed_quantity: 6, position: 3) }

  let(:annotation_items_merge_form) { described_class.new(annotation: annotation) }

  describe("#save(params:)") do
    context "when valid" do
      let(:params) { {annotation_item_ids: [annotation_item_1.id, annotation_item_3.id]} }

      it do
        expect { annotation_items_merge_form.save(params) }
          .to change { annotation.annotation_items.count }.by(-1)
          .and(change { annotation_item_3.reload.present_quantity }.from(5).to(6))
          .and(change(annotation_item_3, :consumed_quantity).from(6).to(8))
          .and(change { annotation_item_3.polygon_set.polygons }.from(original_polygons).to(new_polygons))
          .and(
            change { annotation.annotation_items.reload.order(:position).to_a }
              .from([annotation_item_1, annotation_item_2, annotation_item_3])
              .to([annotation_item_2, annotation_item_3])
          )
        expect(annotation_items_merge_form.errors).to be_empty
      end

      it { expect(annotation_items_merge_form.save(params)).to be_truthy }
    end

    context "when invalid" do
      let(:params) { {annotation_item_ids: [annotation_item_3.id]} }

      it do
        expect { annotation_items_merge_form.save(params) }
          .to not_change { annotation.annotation_items.count }
          .and(not_change { annotation_item_3.reload.present_quantity }.from(5))
          .and(not_change(annotation_item_3, :consumed_quantity).from(6))
          .and(not_change { annotation_item_3.polygon_set.polygons }.from(original_polygons))
          .and(
            not_change { annotation.annotation_items.reload.to_a }
              .from([annotation_item_1, annotation_item_2, annotation_item_3])
          )

        expect(annotation_items_merge_form.errors.full_messages).to eq(["Select at least 2 items to merge"])
      end

      it { expect(annotation_items_merge_form.save(params)).to be_falsy }
    end

    context "when parent_annotation_item.update! raises an error" do
      let(:params) { {annotation_item_ids: [annotation_item_1.id, annotation_item_3.id]} }

      before do
        allow_any_instance_of(AnnotationItem).to receive(:update!).and_raise(ActiveRecord::RecordInvalid.new(annotation_item_3), "Consumed unit can't be blank")
      end

      it do
        expect { annotation_items_merge_form.save(params) }
          .to not_change { annotation.annotation_items.count }
          .and(not_change { annotation_item_3.reload.present_quantity }.from(5))
          .and(not_change(annotation_item_3, :consumed_quantity).from(6))
          .and(not_change { annotation_item_3.polygon_set.polygons }.from(original_polygons))
          .and(
            not_change { annotation.annotation_items.reload.to_a }
              .from([annotation_item_1, annotation_item_2, annotation_item_3])
          )

        expect(annotation_items_merge_form.errors.full_messages).to eq(["Consumed unit can't be blank"])
      end

      it { expect(annotation_items_merge_form.save(params)).to be_falsy }
    end

    context "when parent_annotation_item has no consumed_unit" do
      let(:params) { {annotation_item_ids: [annotation_item_1.id, annotation_item_3.id]} }

      before do
        annotation_item_3.update!(consumed_quantity: nil, consumed_unit: nil)
      end

      it do
        expect { annotation_items_merge_form.save(params) }
          .to change { annotation_item_3.reload.present_quantity }.from(5).to(6)
          .and(change(annotation_item_3, :consumed_quantity).from(nil).to(2))
          .and(change(annotation_item_3, :consumed_unit_id).from(nil).to("g"))
        expect(annotation_items_merge_form.errors).to be_empty
      end

      it { expect(annotation_items_merge_form.save(params)).to be_truthy }
    end
  end

  def original_polygons
    build(:polygon_set).polygons
  end

  def new_polygons
    original_polygons + original_polygons
  end
end
