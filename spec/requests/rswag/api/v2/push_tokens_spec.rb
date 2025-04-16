# frozen_string_literal: true

require "rails_helper"
require "swagger_helper"

# rubocop:disable RSpec/EmptyExampleGroup
RSpec.describe("api/v2/push_tokens", :freeze_swagger_time) do
  let!(:user) { create(:user, id: "b107ca0e-4974-4e51-a6e3-d2ed94a5350c") }

  before { api_sign_in(user) }

  describe "create" do
    path "/api/v2/push_tokens" do
      post("create a push token") do
        tags "Push tokens"
        set_http_headers
        parameter name: :data, in: :body, schema: {
          type: :object,
          properties: {
            data: {
              type: :object,
              properties: {
                attributes: {
                  type: :object,
                  properties: {
                    platform: {
                      type: :string,
                      enum: %w[android ios]
                    },
                    token: {type: :string},
                    locale: {
                      type: :string,
                      enum: I18n.available_locales.map(&:to_s)
                    }
                  },
                  required: %w[platform token locale]
                }
              },
              required: %w[attributes]
            }
          },
          required: %w[data]
        }

        context "when successful" do
          response(200, "OK") do
            let(:data) {
              {
                data: {
                  attributes: {
                    platform: "android",
                    token: "1921e65f6682348d6791efbba818ae3efa8e2e739b314373e2f4f7d1521e793f",
                    locale: "fr"
                  }
                }
              }
            }

            run_test! do |response|
              expect(JSON.parse(response.body)["data"].keys)
                .to contain_exactly("attributes", "relationships", "type", "id")
              expect(JSON.parse(response.body).dig("data", "attributes", "platform"))
                .to eq("android")
            end
          end
        end

        context "when failed" do
          response(422, "Unprocessable Entity") do
            let(:data) {
              {
                data: {
                  attributes: {
                    platform: "",
                    token: "1921e65f6682348d6791efbba818ae3efa8e2e739b314373e2f4f7d1521e793f",
                    locale: "fr"
                  }
                }
              }
            }

            run_test! do |response|
              expect(JSON.parse(response.body))
                .to eq(
                  {
                    "errors" => [
                      {
                        "detail" => "Pushtoken: platform is not included in the list",
                        "source" => {},
                        "title" => "Invalid base"
                      }
                    ],
                    "jsonapi" => {"version" => "1.0"}
                  }
                )
            end
          end
        end
      end
    end
  end
end
# rubocop:enable RSpec/EmptyExampleGroup
