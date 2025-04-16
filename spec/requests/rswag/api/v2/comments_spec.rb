# frozen_string_literal: true

require "rails_helper"
require "swagger_helper"

# rubocop:disable RSpec/EmptyExampleGroup
RSpec.describe("api/v2/comments", :freeze_swagger_time) do
  let(:user) { create(:user, id: "28ffc2db-7c91-4c41-a937-047d5b1b4a32") }

  before { api_sign_in(user) }

  describe "index" do
    path "/api/v2/annotations/{id}/comments" do
      get("list comments") do
        tags "Comments"
        let(:annotation) { create(:annotation, id: "b0b5b0e1-0b5b-4b0b-5b0b-0b5b0b5b0b5b", dish: build(:dish, user: user)) }
        let!(:comment_1) { create(:comment, id: "51aec6f6-927e-475d-8fc2-b8b87c5a047f", annotation: annotation, message: "first comment message") }
        let!(:comment_2) { create(:comment, :from_collaborator, id: "5b7fd99e-342d-4c01-bd85-38b1b608b25e", annotation: annotation, message: "second comment message") }
        let(:id) { annotation.id }
        set_http_headers
        parameter name: :id, in: :path, type: :string
        parameter name: :include, in: :query, type: :string,
          description: include_param_description(Api::V2::CommentPolicy)
        let(:include) { "annotation" }

        context "when successful" do
          response(200, "OK") do
            run_test! do |response|
              expect(JSON.parse(response.body).keys).to contain_exactly("data", "jsonapi", "included", "meta")
            end
          end
        end
      end
    end
  end

  describe "create" do
    path "/api/v2/annotations/{id}/comments" do
      post("create an annotation comment") do
        tags "Comments"
        let(:annotation) { create(:annotation, id: "e7c624f6-46f7-4fc4-8f19-22529460392c", dish: build(:dish, user: user)) }
        let(:id) { annotation.id }
        set_http_headers
        parameter name: :id, in: :path, type: :string
        parameter name: :data, in: :body, schema: {
          type: :object,
          properties: {
            data: {
              type: :object,
              properties: {
                type: {type: :string, enum: %w[comments]},
                attributes: {
                  type: :object,
                  properties: {
                    message: {type: :string, format: "Hello World"}
                  },
                  required: %w[message]
                }
              }
            }
          }
        }
        parameter name: :include, in: :query, type: :string,
          description: include_param_description(Api::V2::CommentPolicy)
        let(:include) { "annotation" }

        context "when successful" do
          response(200, "OK") do
            let(:data) {
              {
                data: {
                  type: :comments,
                  attributes: {
                    message: "Hello World"
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

        context "when failed" do
          response(422, "Unprocessable Entity") do
            let(:data) {
              {
                data: {
                  type: :comments,
                  attributes: {
                    message: nil
                  }
                }
              }
            }

            run_test! do |response|
              expect(JSON.parse(response.body))
                .to eq(
                  "errors" => [
                    {
                      "detail" => "Message can't be blank",
                      "source" => {},
                      "title" => "Invalid message"
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
end
# rubocop:enable RSpec/EmptyExampleGroup
