# frozen_string_literal: true

require "rails_helper"

describe(Collab::Api::V1::AnnotationsController) do
  let(:collaborator_admin) { create(:collaborator, :admin) }
  let(:cohort) { create(:cohort) }
  let(:participation) { create(:participation, cohort: cohort) }
  let!(:annotation_1) { create(:annotation, participation: participation) }
  let!(:annotation_1_dish_image) { create(:dish_image, dish: annotation_1.dish) }
  let!(:annotation_1_comment) { create(:comment, annotation: annotation_1) }
  let!(:annotation_2) { create(:annotation, participation: participation) }
  let!(:annotation_2_intake_2) { create(:intake, annotation: annotation_2) }
  let!(:annotation_2_annotation_item_1) { create(:annotation_item, annotation: annotation_2) }
  let!(:annotation_2_annotation_item_2) { create(:annotation_item, :with_product, annotation: annotation_2) }
  let!(:annotation_2_annotation_item_2_product_image) do
    create(:product_image, product: annotation_2_annotation_item_2.product)
  end
  let(:body) { JSON.parse(response.body) }
  let(:headers) { collab_auth_headers(collaborator_admin) }

  describe "#index" do
    let(:request) do
      get(collab_api_v1_participation_annotations_path(participation), headers: headers, params: params)
    end

    context "without params" do
      let(:params) { {} }

      it do
        request
        expect(body.keys).to contain_exactly("data", "jsonapi", "meta")
        expect(body["data"].size).to eq(2)
        expect(body["data"].pluck("id")).to contain_exactly(annotation_1.id, annotation_2.id)
        expect(body["data"].first.keys).to contain_exactly("id", "type", "attributes", "relationships")
        expect(body["data"].first["attributes"].keys).to contain_exactly("status")
      end
    end

    context "with include param" do
      context "when valid" do
        let(:params) do
          {
            include: "dish,dish.dish_image,intakes,comments,annotation_items,annotation_items.food," \
              "annotation_items.product,annotation_items.product.product_images"
          }
        end

        it do # rubocop:disable RSpec/ExampleLength
          request
          expect(response).to have_http_status(:ok)
          included = body["included"]
          expect(included.filter_map { |i| i["id"] if i["type"] == "dishes" })
            .to match_array([annotation_1.dish, annotation_2.dish].map(&:id))
          expect(included.filter_map { |i| i["id"] if i["type"] == "dish_images" })
            .to contain_exactly(annotation_1.dish.dish_image.id)
          expect(included.filter_map { |i| i["id"] if i["type"] == "intakes" })
            .to match_array([annotation_1.intakes.first, annotation_2.intakes.first, annotation_2.intakes.last].map(&:id))
          expect(included.filter_map { |i| i["id"] if i["type"] == "comments" })
            .to contain_exactly(annotation_1.comments.first.id)
          expect(included.filter_map { |i| i["id"] if i["type"] == "annotation_items" })
            .to match_array([annotation_2_annotation_item_1, annotation_2_annotation_item_2].map(&:id))
          expect(included.filter_map { |i| i["id"] if i["type"] == "foods" })
            .to contain_exactly(annotation_2_annotation_item_1.food.id)
          expect(included.filter_map { |i| i["id"] if i["type"] == "products" })
            .to contain_exactly(annotation_2_annotation_item_2.product.id)
          expect(included.filter_map { |i| i["id"] if i["type"] == "product_images" })
            .to contain_exactly(annotation_2_annotation_item_2.product.product_images.first.id)
        end
      end

      context "when invalid" do
        let(:params) { {include: "invalid"} }

        it do
          request
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    context "with items param" do
      context "with value 1" do
        let(:params) { {items: 1} }

        it do
          request
          expect(body["data"].size).to eq(1)
        end
      end

      context "with default" do
        let(:params) { {} }

        before { create_list(:annotation, 11, participation: participation) }

        it do
          request
          expect(body["data"].size).to eq(10)
        end
      end

      context "when value more than the limit" do
        let(:params) { {items: 25} }

        before { create_list(:annotation, 21, participation: participation) }

        it do
          request
          expect(body["data"].size).to eq(20)
        end
      end
    end
  end
end
