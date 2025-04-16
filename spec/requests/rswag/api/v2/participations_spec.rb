# frozen_string_literal: true

require "rails_helper"
require "swagger_helper"

# rubocop:disable RSpec/EmptyExampleGroup
RSpec.describe("api/v2/participations", :freeze_swagger_time) do
  let(:user) { create(:user, id: "d443f536-f8e1-42fb-8294-d13cd0194752") }
  let!(:paticipation1) { create(:participation, id: "d1a81818-0804-4775-8b6e-57baa8533116", user: user, key: "hqv4DRTub") }
  let!(:paticipation2) { create(:participation, id: "2a9d7656-bf19-4378-8e13-25c327f215e9", user: user, key: "YoAUeWEke") }

  before { api_sign_in(user) }

  describe "index" do
    path "/api/v2/participations" do
      get("list participations") do
        tags "Participations"
        set_http_headers
        parameter name: :include, in: :query, type: :string,
          description: include_param_description(Api::V2::ParticipationPolicy)
        let(:include) { "cohort" }

        after do |example|
          example.metadata[:response][:content] = {
            "application/json" => {example: JSON.parse(response.body, symbolize_names: true)}
          }
        end

        context "when successful" do
          response(200, "OK") do
            run_test! do |response|
              expect(JSON.parse(response.body).keys).to contain_exactly("data", "included", "jsonapi", "meta")
            end
          end
        end
      end
    end
  end
end
# rubocop:enable RSpec/EmptyExampleGroup
