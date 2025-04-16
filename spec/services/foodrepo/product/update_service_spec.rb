# frozen_string_literal: true

require "rails_helper"

describe Foodrepo::Product::UpdateService do
  # Use Coke barcode
  let(:barcode) { "5449000009500" }
  let(:foodrepo_id) { 22784 }
  let(:product) { create(:product, barcode: barcode) }
  let(:foodrepo_product_adapter) { instance_double(Foodrepo::ProductAdapter) }
  let(:service) { described_class.new(product: product, update_remote: update_remote) }

  before do
    allow(Foodrepo::ProductAdapter).to receive(:new).and_return(foodrepo_product_adapter)
    allow(foodrepo_product_adapter).to receive(:create)
    allow(foodrepo_product_adapter).to receive(:update)
  end

  describe "#call", :freeze_time do
    context "when product doesn't exist on FoodRepo" do
      let(:data) { {status: nil} }

      context "when update_remote is true" do
        let(:update_remote) { true }

        it do
          expect { service.call(data: data) }
            .to change(product, :status).from("initial").to("incomplete")
          expect(foodrepo_product_adapter).to have_received(:create).with(no_args)
        end
      end

      context "when update_remote is false" do
        let(:update_remote) { false }

        it do
          expect { service.call(data: data) }
            .to change(product, :status).from("initial").to("incomplete")
          expect(foodrepo_product_adapter).not_to have_received(:create)
        end
      end
    end

    context "when product exists on FoodRepo" do
      context "when product is complete" do
        let(:update_remote) { true }

        let(:data) do
          {
            foodrepo_id: foodrepo_id,
            status: "complete",
            data: {name_en: "Chocolate"}
          }
        end

        it do
          expect { service.call(data: data) }
            .to change { product.reload.name }.from(nil).to("Chocolate")
            .and(change(product, :status).to("complete"))
        end
      end

      context "when product is incomplete" do
        let(:data) do
          {
            foodrepo_id: foodrepo_id,
            status: "incomplete",
            data: {name_en: "Chocolate"}
          }
        end

        context "when update_remote is true" do
          let(:update_remote) { true }

          it do
            expect { service.call(data: data) }
              .to change { product.reload.name }.from(nil).to("Chocolate")
              .and(change(product, :status).to("incomplete"))
            expect(foodrepo_product_adapter).to have_received(:update).with(foodrepo_id: foodrepo_id)
          end
        end

        context "when update_remote is false" do
          let(:update_remote) { false }

          it do
            expect { service.call(data: data) }
              .to change { product.reload.name }.from(nil).to("Chocolate")
              .and(change(product, :status).to("incomplete"))
            expect(foodrepo_product_adapter).not_to have_received(:update)
          end
        end
      end
    end
  end
end
