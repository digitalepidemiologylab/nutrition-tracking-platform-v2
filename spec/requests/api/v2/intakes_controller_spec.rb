# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Api::V2::IntakesController) do
  let(:user) { create(:user, :with_participation) }
  let(:participation) { user.participations.sole }
  let(:body) { JSON.parse(response.body) }

  before { api_sign_in(user) }

  describe "#index" do
    let!(:dish_1) { create(:dish, :with_dish_image, user: user, annotations: [annotation_1]) }
    let!(:annotation_1) { build(:annotation, :with_intakes, dish: nil, participation: participation) }
    let!(:dish_annotation_intake_1_1) { annotation_1.intakes.first }
    let!(:dish_annotation_intake_1_2) { annotation_1.intakes.second }

    let!(:dish_2) { create(:dish, user: user, annotations: [annotation_2]) }
    let!(:annotation_2) { build(:annotation, :with_annotation_item, dish: nil, participation: participation) }
    let!(:dish_annotation_intake_2_1) { annotation_2.intakes.first }
    let!(:annotation_item_annotation_2) { annotation_2.annotation_items.first }

    let!(:annotation_3) { create(:annotation) }
    let!(:dish_annotation_3) { annotation_3.dish }
    let!(:dish_annotation_intake_3_1) { annotation_3.intakes.first }

    before { dish_2.update!(user: user) }

    it do
      get api_v2_intakes_path, headers: auth_params
      expect(body["data"].pluck("id")).to contain_exactly(
        dish_annotation_intake_1_1.id,
        dish_annotation_intake_1_2.id,
        dish_annotation_intake_2_1.id
      )
      expect(body["included"]).to be_nil
    end

    context "with include params" do
      before { get api_v2_intakes_path, headers: auth_params, params: params }

      context "when valid" do
        let(:params) { {include: "annotation.dish.dish_image,annotation.annotation_items.product"} }

        it {
          expect(response).to have_http_status(:ok)
          included = body["included"]
          expect(included.filter_map { |i| i["id"] if i["type"] == "dishes" }).to match_array([dish_1, dish_2].map(&:id))
          expect(included.filter_map { |i| i["id"] if i["type"] == "dish_images" }).to match_array([dish_1.dish_image].map(&:id))
          expect(included.filter_map { |i| i["id"] if i["type"] == "annotations" }).to match_array([annotation_1, annotation_2].map(&:id))
          expect(included.filter_map { |i| i["id"] if i["type"] == "annotation_items" }).to match_array([annotation_item_annotation_2].map(&:id))
          expect(included.filter_map { |i| i["id"] if i["type"] == "products" }).to match_array([annotation_item_annotation_2.product].map(&:id))
        }
      end

      context "when invalid" do
        let(:params) { {include: "invalid"} }

        it { expect(response).to have_http_status(:unprocessable_entity) }
      end
    end

    context "with pagination params" do
      before { get api_v2_intakes_path, headers: auth_params, params: params }

      context "when valid" do
        let(:params) { {page: 1} }

        it { expect(response).to have_http_status(:ok) }
      end

      context "when invalid" do
        let(:params) { {page: 3} }

        it { expect(response).to have_http_status(:not_found) }
      end
    end

    context "with destroyed intakes" do
      let(:paper_trail_version) { instance_double(PaperTrail::Version) }
      let(:intakes_retrieve_destroyed_service) { instance_double(Intakes::RetrieveDestroyedService) }
      let(:request) { get api_v2_intakes_path, headers: auth_params }

      before do
        allow(paper_trail_version).to receive(:[]).with(:item_id).and_return(111)
        allow(Intakes::RetrieveDestroyedService).to receive(:new).and_return(intakes_retrieve_destroyed_service)
        allow(intakes_retrieve_destroyed_service).to receive(:call).and_return([paper_trail_version])
      end

      it do
        request
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)["meta"]).to eq("destroyed_intake_ids" => [111], "last" => 1, "next" => nil, "page" => 1, "prev" => nil)
      end
    end
  end

  describe "#create" do
    let!(:dish) { create(:dish, :with_dish_image, user: user, annotations: [annotation]) }
    let!(:annotation) { build(:annotation, :with_intakes, dish: nil, participation: participation) }
    let(:uuid) { SecureRandom.uuid }
    let(:params) {
      {
        data: {
          type: "intakes",
          id: uuid,
          attributes: {
            consumed_at: (participation.started_at + 1.minute).iso8601,
            timezone: "Asia/Hong_Kong"
          }
        }
      }
    }

    context "when successful" do
      it do
        expect { post api_v2_dish_intakes_path(dish), params: params.to_json, headers: auth_params }
          .to change(dish.annotations.sole.intakes, :count).by(1)
        json_data = JSON.parse(response.body)["data"]
        expect(json_data.keys).to contain_exactly("attributes", "id", "relationships", "type")
        expect(json_data["id"]).to eq(uuid)
      end
    end

    context "when failed" do
      before do
        allow_any_instance_of(Intake)
          .to receive(:valid?)
          .and_return(false)
        allow_any_instance_of(Intake)
          .to receive(:errors)
          .and_return(ActiveModel::Errors.new(Intake.new).tap { |e| e.add(:consumed_at, "cannot be blank") })
      end

      it do
        post api_v2_dish_intakes_path(dish), params: params.to_json, headers: auth_params
        expect(JSON.parse(response.body))
          .to eq(
            "errors" => [
              {
                "detail" => "Consumed at cannot be blank",
                "source" => {},
                "title" => "Invalid consumed_at"
              }
            ],
            "jsonapi" => {"version" => "1.0"}
          )
      end
    end
  end

  describe "#update" do
    let!(:dish) { create(:dish, user: user) }
    let!(:intake) { dish.annotations.sole.intakes.sole }
    let!(:new_consumed_at) { 5.minutes.from_now.iso8601(6) }

    let(:request) { patch(api_v2_intake_path(intake), params: params.to_json, headers: auth_params) }

    context "when successful (valid params)" do
      let(:params) {
        {
          data: {
            type: "intakes",
            attributes: {
              consumed_at: new_consumed_at
            }
          }
        }
      }

      it do
        request
        expect(response).to have_http_status(:success)
        expect(body["data"].keys).to contain_exactly("attributes", "id", "relationships", "type")
        expect(body["data"]["id"]).to eq(intake.id)
        expect(body["data"]["attributes"]["consumed_at"]).to eq(new_consumed_at)
      end
    end

    context "when failed (invalid params)" do
      let(:params) {
        {
          data: {
            type: "intakes",
            attributes: {
              consumed_at: nil
            }
          }
        }
      }

      it do
        request
        expect(response).to have_http_status(:unprocessable_entity)
        expect(body).to eq(
          "errors" => [
            {
              "detail" => "Consumed at can't be blank",
              "source" => {},
              "title" => "Invalid consumed_at"
            }
          ],
          "jsonapi" => {"version" => "1.0"}
        )
      end
    end
  end

  describe "#destroy" do
    context "when dish has one intake" do
      let!(:dish) { create(:dish, user: user) }
      let!(:intake) { dish.annotations.sole.intakes.sole }
      let(:request) { delete api_v2_intake_path(intake), headers: auth_params }

      before { create(:participation, user: user) }

      it do
        expect { request }
          .to change(dish.annotations.sole.intakes, :count).by(-1)
          .and change(Dish, :count).by(-1)
        expect(response).to have_http_status(:success)
      end
    end
  end
end
