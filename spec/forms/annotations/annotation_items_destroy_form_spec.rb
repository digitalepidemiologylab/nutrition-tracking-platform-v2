# frozen_string_literal: true

require "rails_helper"

describe(Annotations::AnnotationItemsDestroyForm) do
  let!(:annotation_item_1) { create(:annotation_item, :with_polygon_set, annotation: annotation, present_quantity: 1, consumed_quantity: 2, position: 1) }
  let!(:annotation_item_2) { create(:annotation_item, :with_polygon_set, annotation: annotation, present_quantity: 3, consumed_quantity: 4, position: 2) }
  let!(:annotation_item_3) { create(:annotation_item, :with_polygon_set, annotation: annotation, present_quantity: 5, consumed_quantity: 6, position: 3) }
  let!(:annotation) { create(:annotation) }

  let(:annotation_items_destroy_form) { described_class.new(annotation: annotation) }

  describe("#save(params:)") do
    let(:params) { {annotation_item_ids: [annotation_item_1.id, annotation_item_3.id]} }

    context "when valid" do
      it do
        expect { annotation_items_destroy_form.save(params) }
          .to change { annotation.annotation_items.count }.by(-2)
          .and(
            change { annotation.annotation_items.reload.order(:position).to_a }
              .from([annotation_item_1, annotation_item_2, annotation_item_3])
              .to([annotation_item_2])
          )
        expect(annotation_items_destroy_form.errors).to be_empty
      end

      it { expect(annotation_items_destroy_form.save(params)).to be_truthy }
    end

    context "when an error is raised" do
      before do
        allow_any_instance_of(AnnotationItem).to receive(:destroy!).and_raise(ActiveRecord::RecordNotDestroyed, "Cannot destroy record")
      end

      it do
        expect { annotation_items_destroy_form.save(params) }
          .to not_change { annotation.annotation_items.count }
          .and(
            not_change { annotation.annotation_items.reload.to_a }
              .from([annotation_item_1, annotation_item_2, annotation_item_3])
          )

        expect(annotation_items_destroy_form.errors.full_messages).to eq(["Cannot destroy record"])
      end

      it { expect(annotation_items_destroy_form.save(params)).to be_falsy }
    end
  end
end
