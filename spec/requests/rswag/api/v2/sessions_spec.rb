# frozen_string_literal: true

require "rails_helper"
require "swagger_helper"

# rubocop:disable RSpec/EmptyExampleGroup
RSpec.describe("api/v2/me/sessions", :freeze_swagger_time) do
  let!(:user) { create(:user, id: "602e9c1a-eb4c-4758-b925-094efb6b5003") }

  describe "sign in" do
    path "/api/v2/me/sign_in" do
      post("create session") do
        tags "Sessions"
        consumes "application/json"
        produces "application/json"
        parameter name: :credentials, in: :body, schema: {
          type: :object,
          properties: {
            data: {
              type: :object,
              properties: {
                type: {type: :string, enum: %w[users]},
                attributes: {
                  type: :object,
                  properties: {
                    email: {
                      default: "user_1@myfoodrepo.org",
                      description: "Email of User to sign in",
                      type: :string
                    },
                    password: {
                      default: "password",
                      description: "Password of User to sign in",
                      type: :string
                    }
                  },
                  required: %w[email password]
                }
              },
              required: %w[attributes]
            }
          },
          required: %w[data]
        }

        context "when successful" do
          response(200, "OK") do
            let(:credentials) {
              {
                data: {
                  type: "users",
                  attributes: {
                    email: user.email,
                    password: user.password
                  }
                }
              }
            }

            run_test! do |response|
              expect(response).to have_http_status(:success)
              expect(JSON.parse(response.body)).to eq(
                "data" => {
                  "type" => "users",
                  "id" => user.reload.id,
                  "attributes" => {
                    "email" => user.email,
                    "anonymous" => false,
                    "dishes_private" => true
                  }
                },
                "jsonapi" => {"version" => "1.0"}
              )
              expect(response.headers.keys).to include("access-token", "uid", "client", "token-type")
            end
          end
        end

        context "when failed" do
          response(401, "Unauthorized") do
            let(:credentials) {
              {
                data: {
                  type: "users",
                  attributes: {
                    email: user.email,
                    password: "wrong password"
                  }
                }
              }
            }

            run_test! do |response|
              expect(JSON.parse(response.body))
                .to eq(
                  "errors" => [
                    {"detail" => "Invalid login credentials. Please try again."}
                  ],
                  "jsonapi" => {"version" => "1.0"}
                )
            end
          end
        end
      end
    end
  end

  describe "sign out" do
    path "/api/v2/me/sign_out" do
      delete("delete session") do
        tags "Sessions"
        set_http_headers

        response(200, "OK") do
          before { api_sign_in(user) }

          run_test! do |response|
            expect(response).to have_http_status(:success)
            expect(JSON.parse(response.body)).to be_empty
          end
        end
      end
    end
  end
end
# rubocop:enable RSpec/EmptyExampleGroup
