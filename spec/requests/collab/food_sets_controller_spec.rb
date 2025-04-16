# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Collab::FoodSetsController) do
  let(:collaborator) { create(:collaborator, :admin) }
  let(:food_set) { create(:food_set) }

  before { sign_in(collaborator) }

  describe "#index" do
    it do
      get collab_food_sets_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "#show" do
    it do
      get collab_food_set_path(food_set)
      expect(response).to have_http_status(:success)
    end
  end

  describe "#new" do
    it do
      get new_collab_food_set_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "#create" do
    let(:request) { post collab_food_sets_path, params: {food_set: params} }

    context "with valid params" do
      let(:params) do
        {
          name: "A great study",
          cname: "a_cname",
          name_en: "name en",
          name_de: "name de",
          name_fr: "name fr"
        }
      end

      it do
        request
        food_set_created = FoodSet.last
        expect(response).to redirect_to(collab_food_set_path(food_set_created))
        expect(food_set_created.name).to eq("name en")
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
    it do
      get edit_collab_food_set_path(food_set)
      expect(response).to have_http_status(:success)
    end
  end

  describe "#update" do
    let(:request) { put collab_food_set_path(food_set), params: {food_set: params} }

    context "with valid params" do
      let(:params) { {cname: "a_new_cname"} }

      it do
        request
        expect(response).to redirect_to(collab_food_set_path(food_set))
        expect(food_set.reload.cname).to eq("a_new_cname")
      end
    end

    context "with invalid params" do
      let(:params) { {cname: "", name_en: ""} }

      it do
        request
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "#destroy" do
    let(:request) { delete collab_food_set_path(food_set) }

    context "when successful" do
      it do
        request
        expect(response).to redirect_to(collab_food_sets_path)
      end
    end

    context "with failed" do
      before do
        allow_any_instance_of(FoodSet).to receive(:destroy).and_return(false)
      end

      it do
        request
        expect(response).to redirect_to(collab_food_set_path(food_set))
      end
    end
  end
end
