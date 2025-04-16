# frozen_string_literal: true

require "rails_helper"
require "swagger_helper"

# rubocop:disable RSpec/EmptyExampleGroup
RSpec.describe("api/v2/products", :freeze_swagger_time) do
  let(:user) { create(:user, id: "402a7a1c-b2be-4f66-8107-c024263746e9") }

  before { api_sign_in(user) }

  describe "index" do
    before do
      create_list(:product, 3)
    end

    path "/api/v2/products" do
      get("list products") do
        tags "Products"
        set_http_headers
        parameter name: :page, in: :query, type: :integer,
          description: "Page number"
        parameter name: :items, in: :query, type: :integer,
          description: "Number of items per page (default is #{Pagy::DEFAULT[:items]}, max is #{Api::V2::ProductsController::MAX_ITEMS})"
        let(:page) { "1" }
        let(:items) { "5" }

        context "when successful" do
          response(200, "OK") do
            run_test! do |response|
              expect(JSON.parse(response.body).keys).to contain_exactly("data", "meta", "jsonapi")
            end
          end
        end
      end
    end
  end
end
# rubocop:enable RSpec/EmptyExampleGroup
