# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Collab::CohortsController) do
  let(:collaborator) { create(:collaborator, :admin) }
  let(:cohort) { create(:cohort) }

  before { sign_in(collaborator) }

  describe "#index" do
    it do
      get collab_cohorts_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "#show" do
    it do
      get collab_cohort_path(cohort)
      expect(response).to have_http_status(:success)
    end
  end

  describe "#new" do
    it do
      get new_collab_cohort_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "#create" do
    let(:request) { post collab_cohorts_path, params: {cohort: params} }

    context "with valid params" do
      let(:segmentation_client) { create(:segmentation_client) }
      let(:food_list) { create(:food_list) }
      let(:params) do
        {
          name: "A great study",
          food_list_ids: [food_list.id],
          segmentation_client_id: segmentation_client.id
        }
      end

      it do
        request
        cohort_created = Cohort.last
        expect(response).to redirect_to(collab_cohort_path(cohort_created))
        expect(cohort_created.name).to eq("A great study")
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
      get edit_collab_cohort_path(cohort)
      expect(response).to have_http_status(:success)
    end
  end

  describe "#update" do
    let(:request) { put collab_cohort_path(cohort), params: {cohort: params} }

    context "with valid params" do
      let(:params) { {name: "A new study name"} }

      it do
        request
        expect(response).to redirect_to(collab_cohort_path(cohort))
        expect(cohort.reload.name).to eq("A new study name")
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
end
