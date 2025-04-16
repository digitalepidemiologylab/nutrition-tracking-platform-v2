# frozen_string_literal: true

require "rails_helper"
require "swagger_helper"

# rubocop:disable RSpec/EmptyExampleGroup
RSpec.describe("api/v2/direct_uploads", :freeze_swagger_time) do
  let!(:user) { create(:user, id: "e1b7308e-40d6-41ad-a7b6-f729cbfe3021") }

  before do
    api_sign_in(user)
  end

  describe "create" do
    path "/api/v2/direct_uploads" do
      post("create a direct_upload") do
        tags "Direct uploads"
        set_http_headers
        parameter name: :data, in: :body, schema: {
          type: :object,
          properties: {
            data: {
              type: :object,
              properties: {
                type: {type: :string, enum: %w[direct_uploads]},
                attributes: {
                  type: :object,
                  properties: {
                    filename: {type: :string},
                    byte_size: {type: :integer},
                    checksum: {
                      type: :string,
                      description: %(
                        Base64-encoded 128-bit MD5 digest,
                        see https://aws.amazon.com/premiumsupport/knowledge-center/data-integrity-s3/
                      )
                    },
                    content_type: {type: :string}
                  }
                }
              },
              required: %w[attributes]
            }
          },
          required: %w[data]
        }
        let(:data) do
          {
            data: {
              type: "direct_uploads",
              attributes: {
                filename: "test.jpg",
                byte_size: 1234,
                checksum: "checksum",
                content_type: "image/jpeg"
              }
            }
          }
        end

        context "when successful" do
          response(200, "OK") do
            run_test! do |response|
              expect(JSON.parse(response.body)["data"].keys).to contain_exactly("id", "type", "attributes")
              expect(JSON.parse(response.body)["data"]["attributes"].keys).to contain_exactly("url", "headers")
            end
          end
        end

        context "when failed" do
          before do
            allow(ActiveStorage::Blob).to receive(:create_before_direct_upload!).and_raise(ActiveStorage::Error)
          end

          response(500, "Internal server error") do
            run_test! do |response|
              expect(JSON.parse(response.body))
                .to eq(
                  {
                    "errors" => [
                      {
                        "title" => "ActiveStorage::Error",
                        "detail" => "Internal server error"
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
