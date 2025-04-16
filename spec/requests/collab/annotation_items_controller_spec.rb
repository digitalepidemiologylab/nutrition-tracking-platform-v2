# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Collab::AnnotationItemsController) do
  let(:collaborator) { create(:collaborator, :admin) }
  let!(:annotation_item) { create(:annotation_item) }
  let!(:annotation) { annotation_item.annotation }
  let!(:food_1) { create(:food, food_list: annotation_item.food.food_list) }

  before do
    create_base_units
    sign_in(collaborator)
  end

  describe "#update" do
    context "with turbo_stream format" do
      let(:request) {
        put collab_annotation_item_path(annotation_item), params: {annotation_item: params},
          headers: turbo_stream_headers
      }

      context "with valid params" do
        let(:params) do
          {
            food_id: food_1.id,
            present_quantity: 333,
            present_unit_id: "g",
            consumed_quantity: 50,
            consumed_unit_id: "%"
          }
        end

        it do
          expect { request }
            .to change { annotation_item.reload.consumed_quantity }.to(166.5)
          expect(response.body).to match("<turbo-stream action=\"replace\"")
          expect(response.body).not_to match("Item must exist")
        end
      end

      context "with invalid params" do
        let(:params) do
          {
            food_id: "",
            present_quantity: 333,
            present_unit_id: "g",
            consumed_quantity: 50,
            consumed_unit_id: "%"
          }
        end

        it do
          expect { request }
            .to change { annotation_item.reload.consumed_quantity }.to(166.5)
          expect(response.body).to match("<turbo-stream action=\"replace\"")
          expect(response.body).to match("Barcode can&#39;t be blank")
        end
      end
    end
  end

  describe "#destroy" do
    context "with turbo_stream format" do
      let(:request) { delete collab_annotation_item_path(annotation_item), headers: turbo_stream_headers }

      context "when success" do
        it do
          expect { request }
            .to change(AnnotationItem, :count).by(-1)
          expect(response.body).to include("<turbo-stream action=\"remove\"")
        end
      end

      context "when failed" do
        before do
          allow_any_instance_of(AnnotationItem).to receive(:destroy).and_return(false)
        end

        it do
          expect { request }
            .not_to change(AnnotationItem, :count)
          expect(response.body).not_to include("<turbo-stream action=\"remove\"")
          expect(response.body).to include("<turbo-stream action=\"update\"")
          expect(response.body).to include("Unable to remove item")
        end
      end
    end
  end
end
