# frozen_string_literal: true

require "rails_helper"
require "swagger_helper"

# rubocop:disable RSpec/EmptyExampleGroup
RSpec.describe("api/v2/me", :freeze_swagger_time) do
  let!(:user) { create(:user, id: "a91d4646-2209-422d-8cc5-431d9f2e06b2") }

  before { api_sign_in(user) }

  describe "show" do
    path "/api/v2/me" do
      get("show me") do
        tags "Users"
        set_http_headers

        response(200, "OK") do
          run_test! do |response|
            expect(JSON.parse(response.body)["data"].keys).to contain_exactly("attributes", "id", "type")
          end
        end
      end
    end
  end
end
# rubocop:enable RSpec/EmptyExampleGroup
