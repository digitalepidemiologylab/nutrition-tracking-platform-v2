# frozen_string_literal: true

require "rails_helper"

describe(Collab::Api::V1::CohortsController) do
  let(:collaborator_admin) { create(:collaborator, :admin) }
  let(:cohort) { create(:cohort, :with_food_list) }
  let!(:participation) { create(:participation, cohort: cohort) }
  let(:headers) { collab_auth_headers(collaborator_admin) }
  let(:body) { JSON.parse(response.body) }

  describe "#show" do
    it do
      get(collab_api_v1_cohort_path(cohort), headers: headers)
      expect(body.keys).to contain_exactly("data", "jsonapi")
    end

    context "with include params" do
      it do
        get(collab_api_v1_cohort_path(cohort), headers: headers, params: {include: "food_lists"})
        expect(body.keys).to contain_exactly("data", "included", "jsonapi")
        expect(body["included"].count { |i| i["type"] == "food_lists" }).to eq(1)
      end
    end
  end
end
