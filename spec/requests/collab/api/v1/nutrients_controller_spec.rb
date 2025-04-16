# frozen_string_literal: true

require "rails_helper"

describe(Collab::Api::V1::NutrientsController) do
  let(:collaborator_admin) { create(:collaborator, :admin) }
  let(:body) { JSON.parse(response.body) }
  let(:headers) { collab_auth_headers(collaborator_admin) }

  describe "#index" do
    let(:request) { get(collab_api_v1_nutrients_path, headers: headers, params: params) }

    before { create_list(:nutrient, 2) }

    context "without items param" do
      let(:params) { {} }

      it do
        request
        expect(response).to(have_http_status(:ok))
        expect(body.keys).to contain_exactly("data", "jsonapi", "meta")
        expect(body["data"].size).to eq(2)
        expect(body["data"].first.keys).to contain_exactly("id", "type", "attributes", "relationships")
        expect(body["data"].first["relationships"].keys).to contain_exactly("unit")
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

      context "when no value" do
        let(:params) { {} }

        before { create_list(:nutrient, 251) }

        it do
          request
          expect(body["data"].size).to eq(250)
        end
      end

      context "when value more than the limit" do
        let(:params) { {items: 300} }

        before { create_list(:nutrient, 251) }

        it do
          request
          expect(body["data"].size).to eq(250)
        end
      end
    end
  end
end
