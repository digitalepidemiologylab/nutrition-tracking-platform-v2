# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Collab::FoodListsController) do
  let(:collaborator) { create(:collaborator, :admin) }

  before { sign_in(collaborator) }

  describe "#index" do
    before { create_list(:food_list, 2) }

    it do
      get collab_food_lists_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "#show" do
    let(:food_list) { create(:food_list) }

    it do
      get collab_food_list_path(food_list)
      expect(response).to have_http_status(:success)
    end
  end

  describe "#edit" do
    let(:food_list) { create(:food_list, :editable) }

    it do
      get edit_collab_food_list_path(food_list)
      expect(response).to have_http_status(:success)
    end
  end

  describe "#update" do
    let(:food_list) { create(:food_list, :editable) }
    let(:request) { put collab_food_list_path(food_list), params: {food_list: params} }

    context "with valid params" do
      let(:params) { {name: "a_new_name"} }

      it do
        request
        expect(response).to redirect_to(collab_food_list_path(food_list))
        expect(flash[:notice]).to eq("Food list updated successfully")
        expect(food_list.reload.name).to eq("a_new_name")
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

  describe "#destroy" do
    let(:food_list) { create(:food_list, :editable) }
    let(:request) { delete collab_food_list_path(food_list) }

    context "when successful" do
      it do
        request
        expect(response).to redirect_to(collab_food_lists_path)
      end
    end

    context "when failed" do
      before do
        allow_any_instance_of(FoodList).to receive(:destroy).and_return(false)
      end

      it do
        request
        expect(response).to redirect_to(collab_food_list_path(food_list))
        expect(flash[:alert]).to eq("Unable to delete the food list")
      end
    end
  end
end
