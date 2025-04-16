# frozen_string_literal: true

require "rails_helper"
require "swagger_helper"

# rubocop:disable RSpec/EmptyExampleGroup
RSpec.describe("api/v2/participate", :freeze_swagger_time) do
  let!(:user) { create(:user, id: "0ec18ae8-490a-49ab-9e5e-9387317784dd") }

  before { api_sign_in(user) }

  path "/api/v2/participate" do
    post("participate to a cohort") do
      tags "Participations"
      set_http_headers
      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          data: {
            type: :object,
            properties: {
              type: {type: :string, enum: ["participations"]},
              attributes: {
                type: :object,
                properties: {
                  key: {type: :string}
                }
              }
            },
            required: %w[attributes]
          }
        },
        required: %w[data]
      }

      context "when successful" do
        let!(:participation) { create(:participation, :not_associated, id: "4c55af60-e9bb-461d-95f1-cd2034994bcb", key: "r96wSbSqg") }

        response(200, "OK") do
          let(:data) {
            {
              data: {
                type: :participations,
                attributes: {
                  key: participation.key
                }
              }
            }
          }

          run_test! do |response|
            expect(JSON.parse(response.body)["data"].keys)
              .to contain_exactly("attributes", "relationships", "type", "id")
          end
        end
      end

      context "when forbidden" do
        let!(:participation) { create(:participation, id: "a603c509-5ca7-42d8-a888-90a5b97dab4e", key: "YUibKQKNd", user: create(:user, id: "6b055df4-7155-4cbd-8c04-8b01553c4eee")) }

        response(403, "Forbidden") do
          let(:data) {
            {
              data: {
                type: :participations,
                attributes: {
                  key: participation.key
                }
              }
            }
          }

          run_test! do |response|
            expect(JSON.parse(response.body))
              .to eq(
                "errors" => [{"detail" => "not allowed to create? this Participation", "title" => "Pundit::NotAuthorizedError"}],
                "jsonapi" => {"version" => "1.0"}
              )
          end
        end
      end

      context "when participation not found" do
        response(404, "Not Found") do
          let(:data) {
            {
              data: {
                type: :participations,
                attributes: {
                  key: "invalid"
                }
              }
            }
          }

          run_test! do |response|
            expect(JSON.parse(response.body))
              .to eq(
                "errors" => [{"detail" => "Participation not found", "title" => "ActiveRecord::RecordNotFound"}],
                "jsonapi" => {"version" => "1.0"}
              )
          end
        end
      end
    end
  end
end
# rubocop:enable RSpec/EmptyExampleGroup
