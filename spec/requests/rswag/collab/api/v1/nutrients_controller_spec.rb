# frozen_string_literal: true

require "rails_helper"
require "swagger_helper"

# rubocop:disable RSpec/EmptyExampleGroup
describe("/collab/api/v1/nutrients", :freeze_swagger_time, swagger_doc: "collab/v1/swagger.json") do
  let(:collaborator) { create(:collaborator, id: "c30cb9f3-3285-4008-8bc1-ceac53588b1d") }
  let(:headers) { collab_auth_headers(collaborator) }

  describe "index" do
    before { create_list(:nutrient, 2) }

    path "/collab/api/v1/nutrients" do
      get("list nutrients") do
        tags "Nutrients"
        set_http_headers
        parameter name: :page, in: :query, type: :integer, description: "Page number"
        parameter name: :items, in: :query, type: :integer,
          description: "Number of items per page (default is " \
            "#{Collab::Api::V1::NutrientsController::DEFAULT_ITEMS}, " \
            "max is #{Collab::Api::V1::NutrientsController::MAX_ITEMS})"
        let(:page) { "1" }
        let(:items) { "5" }

        context "when successful" do
          response(200, "OK") do
            run_test! do |response|
              body = JSON.parse(response.body)
              expect(body["data"].size).to eq(2)
              expect(body["data"].first.keys).to contain_exactly("id", "type", "attributes", "relationships")
            end
          end
        end
      end
    end
  end
end
# rubocop:enable RSpec/EmptyExampleGroup
