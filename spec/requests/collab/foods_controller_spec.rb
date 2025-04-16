# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Collab::FoodsController) do
  let(:collaborator) { create(:collaborator, :admin) }

  before { sign_in(collaborator) }

  describe "#index" do
    let!(:food) { create(:food) }
    let!(:food_with_food_set) { create(:food, :with_food_set) }

    it do
      get collab_foods_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "#show" do
    let(:food) { create(:food, :with_food_set) }

    it do
      get collab_food_path(food)
      expect(response).to have_http_status(:success)
    end
  end

  describe "#new" do
    it do
      get new_collab_food_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "#create" do
    let!(:unit) { create(:unit) }
    let!(:food_set) { create(:food_set) }
    let!(:food_list) { create(:food_list, :editable) }
    let(:request) { post collab_foods_path, params: {food: params} }

    context "with valid params" do
      let(:params) do
        {
          unit_id: unit.id,
          portion_quantity: 123.4,
          food_set_id: food_set.id,
          food_list_id: food_list.id,
          name_en: "name en",
          name_de: "name de",
          name_fr: "name fr"
        }
      end

      it do
        request
        food_created = Food.last
        expect(response).to redirect_to(collab_food_path(food_created))
        expect(flash[:notice]).to eq("Food created successfully")
        expect(food_created.name).to eq("name en")
      end
    end

    context "with invalid params" do
      let(:params) { {name: ""} }

      it do
        request
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "#edit" do
    let(:food) { create(:food, :editable) }

    it do
      get edit_collab_food_path(food)
      expect(response).to have_http_status(:success)
    end
  end

  describe "#update" do
    let(:food) { create(:food, :editable) }
    let(:request) { put collab_food_path(food), params: {food: params} }

    context "with valid params" do
      let(:params) { {name_en: "a_new_name"} }

      it do
        request
        expect(response).to redirect_to(collab_food_path(food))
        expect(flash[:notice]).to eq("Food updated successfully")
        expect(food.reload.name).to eq("a_new_name")
      end
    end

    context "with invalid params" do
      let(:params) { {name: "", name_en: ""} }

      it do
        request
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "#destroy" do
    let(:food) { create(:food, :editable) }
    let(:request) { delete collab_food_path(food) }

    context "when successful" do
      it do
        request
        expect(response).to redirect_to(collab_foods_path)
      end
    end

    context "when failed" do
      before do
        allow_any_instance_of(Food).to receive(:destroy).and_return(false)
      end

      it do
        request
        expect(response).to redirect_to(collab_food_path(food))
        expect(flash[:alert]).to eq("Unable to destroy the food")
      end
    end
  end
end
