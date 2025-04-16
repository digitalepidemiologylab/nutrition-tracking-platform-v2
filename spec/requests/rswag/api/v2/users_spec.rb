# frozen_string_literal: true

require "rails_helper"
require "swagger_helper"

# rubocop:disable RSpec/EmptyExampleGroup
RSpec.describe("api/v2/me", :freeze_swagger_time) do
  path "/api/v2/me" do
    describe "create" do
      let!(:participation) { create(:participation, :not_associated, id: "51053567-eda4-4bee-b2db-b62bba7c3fcd", key: "mBzGSFn4K") }

      post("create user with participation key (sign up)") do
        tags "Users"
        consumes("application/json")
        produces("application/json")
        parameter name: :data, in: :body, schema: {
          type: :object,
          properties: {
            data: {
              type: :object,
              properties: {
                type: {type: :string, enum: %w[participations]},
                attributes: {
                  type: :object,
                  properties: {
                    key: {type: :string}
                  },
                  required: %w[key]
                }
              },
              required: %w[attributes]
            }
          },
          required: %w[data]
        }

        context "when OK" do
          response(200, "OK") do
            let(:data) {
              {
                data: {
                  type: "participations",
                  attributes: {
                    key: participation.key
                  }
                }
              }
            }

            run_test! do |response|
              expect(response).to have_http_status(:success)
              user = User.last
              expect(JSON.parse(response.body)).to eq(
                "data" => {
                  "type" => "users",
                  "id" => user.reload.id,
                  "attributes" => {
                    "email" => user.email,
                    "dishes_private" => true,
                    "anonymous" => true
                  }
                },
                "jsonapi" => {"version" => "1.0"}
              )
              expect(response.headers.keys).to include("access-token", "uid", "client", "token-type")
            end
          end
        end

        context "when Unprocessable Entity" do
          response(422, "Unprocessable Entity") do
            let(:data) {
              {
                data: {
                  type: "participations",
                  attributes: {
                    key: "bad_key"
                  }
                }
              }
            }

            run_test! do |response|
              expect(JSON.parse(response.body)).to eq(
                "errors" => [
                  {
                    "detail" => "Key doesn't exist",
                    "source" => {},
                    "title" => "Invalid key"
                  }
                ],
                "jsonapi" => {"version" => "1.0"}
              )
            end
          end
        end
      end
    end

    describe "update" do
      let!(:user) { create(:user, :anonymous, id: "c2de1037-654c-4567-9671-25bc6495bb67") }
      let!(:new_password) { "a_new_password" }
      let!(:new_email) { "new_email@myfoodrepo.org" }

      before { api_sign_in(user) }

      patch("update user email and/or password") do
        tags "Users"
        set_http_headers
        parameter name: :data, in: :body, schema: {
          type: :object,
          properties: {
            type: {type: :string, enum: ["users"]},
            attributes: {
              type: :object,
              properties: {
                email: {type: :string},
                password: {type: :string},
                password_confirmation: {type: :string},
                dishes_private: {type: :boolean}
              }
            }
          }
        }

        context "when successful" do
          response(200, "OK") do
            let(:data) {
              {
                data: {
                  type: :users,
                  attributes: {
                    email: new_email,
                    password: new_password,
                    password_confirmation: new_password,
                    dishes_private: true
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
                    "dishes_private" => true,
                    "anonymous" => false
                  }
                },
                "jsonapi" => {"version" => "1.0"}
              )
              expect(response.headers.keys).to include("access-token", "uid", "client", "token-type")
            end
          end
        end

        context "when Unprocessable Entity" do
          response(422, "Unprocessable Entity") do
            let(:data) {
              {
                data: {
                  type: "users",
                  attributes: {
                    email: new_email,
                    password: new_password,
                    password_confirmation: "bad_email",
                    dishes_private: true
                  }
                }
              }
            }

            run_test! do |response|
              expect(JSON.parse(response.body)).to eq(
                "errors" => [
                  {
                    "detail" => "User: password_confirmation doesn't match Password",
                    "source" => {},
                    "title" => "Invalid base"
                  }
                ],
                "jsonapi" => {"version" => "1.0"}
              )
            end
          end
        end
      end
    end
  end

  describe "destroy" do
    let(:user) { create(:user) }

    before { api_sign_in(user) }

    path "/api/v2/me" do
      delete("delete my account") do
        tags "Users"
        set_http_headers

        context "when OK" do
          response(200, "No Content") do
            run_test! do |response|
              expect(response).to have_http_status(:ok)
              expect(JSON.parse(response.body)).to eq(
                "data" => nil,
                "meta" => {
                  "message" => "Your personal data has been deleted. " \
                    "Please note that all your dish images have been collected on behalf of a cohort. " \
                    "You must contact the cohort if you want your images and their associated data to be deleted."
                },
                "jsonapi" => {"version" => "1.0"}
              )
            end
          end
        end

        context "when not found" do
          response(404, "Not Found") do
            before { user.destroy! }

            run_test! do |response|
              expect(response).to have_http_status(:not_found)
              expect(JSON.parse(response.body)).to eq(
                "errors" => [
                  {"detail" => "Unable to locate account for destruction."}
                ],
                "jsonapi" => {"version" => "1.0"}
              )
            end
          end
        end
      end
    end
  end
end
# rubocop:enable RSpec/EmptyExampleGroup
