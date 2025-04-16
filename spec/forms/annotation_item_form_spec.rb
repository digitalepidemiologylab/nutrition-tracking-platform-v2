# frozen_string_literal: true

require "rails_helper"

describe(AnnotationItemForm) do
  let!(:annotation) { create(:annotation) }
  let!(:annotation_item) { build(:annotation_item, :with_product, annotation: annotation) }
  let!(:valid_barcode) { "7610128737127" }
  let!(:invalid_barcode) { "invalid barcode" }
  let!(:annotation_item_form) { described_class.new(annotation_item: annotation_item) }

  it do
    expect(annotation_item_form).to respond_to(:annotation_item)
  end

  describe "#save(params)" do
    context "when params valid" do
      let(:params) { {barcode: valid_barcode} }

      it { expect(annotation_item_form.save(params)).to be_truthy }

      it do
        expect { annotation_item_form.save(params) }
          .to change(annotation_item, :barcode).to(valid_barcode)
          .and(change(annotation_item, :persisted?).to(true))
          .and(not_change(annotation_item, :errors))
      end
    end

    context "when params invalid" do
      let(:params) { {barcode: nil} }

      it { expect(annotation_item_form.save(params)).to be_falsey }

      it do
        expect { annotation_item_form.save(params) }
          .to change(annotation_item, :barcode).to(nil)
          .and(change(annotation_item, :persisted?).to(true))
          .and(change(annotation_item.errors, :full_messages).from([]).to(["Barcode can't be blank"]))
      end
    end

    context "when exception is raised" do
      let(:params) { {barcode: invalid_barcode} }

      it { expect(annotation_item_form.save(params)).to be_falsey }

      it do
        expect { annotation_item_form.save(params) }
          .to change(annotation_item, :barcode).to(invalid_barcode)
          .and(change(annotation_item, :persisted?).to(true))
          .and(change(annotation_item.errors, :full_messages).from([]).to(["Barcode must be a valid EAN or UPC barcode"]))
      end
    end
  end
end
