# frozen_string_literal: true

require "rails_helper"
require "swagger_helper"

# rubocop:disable RSpec/EmptyExampleGroup
RSpec.describe("api/v2/intakes", :freeze_swagger_time) do
  let!(:user) { create(:user, id: "402a7a1c-b2be-4f66-8107-c024263746e9") }
  let!(:participation) { create(:participation, user: user, id: "7b8066fd-d11f-435b-9f38-d4ec97ce135c") }
  let!(:dish) { create(:dish, :with_dish_image, id: "5ad1aa0e-7463-41bf-b43f-9a0740aaac6d", user: user, annotations: [annotation]) }
  let!(:annotation) { build(:annotation, :with_intakes, dish: nil, participation: participation) }

  before { api_sign_in(user) }

  describe "index" do
    let(:paper_trail_version) { instance_double(PaperTrail::Version) }
    let(:intakes_retrieve_destroyed_service) { instance_double(Intakes::RetrieveDestroyedService) }
    let(:destroyed_intake_id) { "7b8066fd-d11f-435b-9f38-d4ec97ce135c" }

    before do
      allow(paper_trail_version).to receive(:[]).with(:item_id).and_return(destroyed_intake_id)
      allow(Intakes::RetrieveDestroyedService).to receive(:new).and_return(intakes_retrieve_destroyed_service)
      allow(intakes_retrieve_destroyed_service).to receive(:call).and_return([paper_trail_version])
      create_list(:annotation, 2, :with_annotation_items, dish: dish)
    end

    path "/api/v2/intakes" do
      get("list intakes") do
        tags "Intakes"
        description "List intakes.<br>When successful, the response contains a list of intakes and a meta object with pagination information and a list of destroyed intakes ids. This list can be used to hide displayed destroyed intakes from a client UI."
        set_http_headers
        parameter name: :"filter[updated_at_gt]", in: :query, type: :string
        parameter name: :page, in: :query, type: :integer,
          description: "Page number"
        parameter name: :items, in: :query, type: :integer,
          description: "Number of items per page (default is #{Pagy::DEFAULT[:items]}, max is #{Pagy::DEFAULT[:max_items]})"
        parameter name: :include, in: :query, type: :string,
          description: include_param_description(Api::V2::IntakePolicy)
        let(:page) { "1" }
        let(:items) { "5" }
        let(:include) { "annotation.dish.dish_image" }

        context "when successful" do
          response(200, "OK") do
            let(:"filter[updated_at_gt]") { 2.hours.ago } # rubocop:disable  RSpec/VariableName

            run_test! do |response|
              expect(JSON.parse(response.body).keys).to contain_exactly("data", "meta", "jsonapi", "included")
              expect(JSON.parse(response.body)["meta"]).to eq({"destroyed_intake_ids" => [destroyed_intake_id], "last" => 1, "next" => nil, "page" => 1, "prev" => nil})
            end
          end
        end

        context "when Unprocessable Entity" do
          response(422, "Unprocessable Entity") do
            let(:"filter[updated_at_gt]") { "a_wrong_date" } # rubocop:disable  RSpec/VariableName

            run_test! do |response|
              expect(JSON.parse(response.body)).to eq("errors" => [{"detail" => "invalid date", "title" => "BaseQuery::BadFilterParam"}],
                "jsonapi" => {"version" => "1.0"})
            end
          end
        end
      end
    end
  end

  describe "create" do
    path "/api/v2/dishes/{id}/intakes" do
      post("create a dish intake") do
        tags "Intakes"
        let(:id) { dish.id }
        set_http_headers
        parameter name: :id, in: :path, type: :string
        parameter name: :data, in: :body, schema: {
          type: :object,
          properties: {
            data: {
              type: :object,
              properties: {
                type: {type: :string, enum: ["intakes"]},
                attributes: {
                  type: :object,
                  properties: {
                    consumed_at: {type: :string, format: "date-time"},
                    timezone: {type: :string, enum: ["Asia/Hong_Kong", "Etc/UTC"]}
                  },
                  required: %w[consumed_at timezone]
                }
              },
              required: %w[attributes]
            }
          },
          required: %w[data]
        }
        parameter name: :include, in: :query, type: :string,
          description: include_param_description(Api::V2::IntakePolicy)
        let(:include) { "annotation.dish.dish_image" }

        context "when successful" do
          response(200, "OK") do
            let(:data) {
              {
                data: {
                  type: :intakes,
                  attributes: {
                    consumed_at: Time.current.iso8601,
                    timezone: "Asia/Hong_Kong"
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
                  type: :intakes,
                  attributes: {
                    consumed_at: nil,
                    timezone: "Asia/Hong_Kong"
                  }
                }
              }
            }

            run_test! do |response|
              expect(JSON.parse(response.body))
                .to eq(
                  "errors" => [
                    {
                      "detail" => "Consumed at can't be blank",
                      "source" => {},
                      "title" => "Invalid consumed_at"
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

  describe "update" do
    let!(:intake) { annotation.intakes.first }
    let!(:id) { intake.id }

    path "/api/v2/intakes/{id}" do
      patch("update an intake") do
        tags "Intakes"
        set_http_headers
        parameter name: :id, in: :path, type: :string
        parameter name: :data, in: :body, schema: {
          type: :object,
          properties: {
            data: {
              type: :object,
              properties: {
                type: {type: :string, enum: ["intakes"]},
                attributes: {
                  type: :object,
                  properties: {
                    consumed_at: {type: :string, format: "date-time"}
                  }
                }
              }
            }
          }
        }
        parameter name: :include, in: :query, type: :string,
          description: include_param_description(Api::V2::IntakePolicy)
        let(:include) { "annotation.dish.dish_image" }

        before { allow(Intake).to receive(:find).and_return(intake) }

        context "when successful" do
          response(200, "OK") do
            let(:data) {
              {
                data: {
                  type: :intakes,
                  attributes: {
                    consumed_at: Time.current.iso8601(6)
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
                  type: :intakes,
                  attributes: {
                    consumed_at: nil
                  }
                }
              }
            }

            run_test! do |response|
              expect(JSON.parse(response.body))
                .to eq(
                  "errors" => [
                    {
                      "detail" => "Consumed at can't be blank",
                      "source" => {},
                      "title" => "Invalid consumed_at"
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
    path "/api/v2/intakes/{id}" do
      delete("delete intake") do
        tags "Intakes"
        let(:id) { dish.annotations.sole.intakes.first.id }
        set_http_headers
        parameter name: :id, in: :path, type: :string

        context "when OK" do
          response(204, "No Content") do
            run_test! do |response|
              expect(response).to have_http_status(:no_content)
            end
          end
        end

        context "when Forbidden" do
          response(403, "Forbidden") do
            let(:other_user) { create(:user, id: "5BAA29D1-86AA-4226-AE1D-480A0CCDB191") }

            before { api_sign_in(other_user) }

            run_test! do |response|
              expect(JSON.parse(response.body)).to eq(
                "errors" => [{"detail" => "not allowed to destroy? this Intake", "title" => "Pundit::NotAuthorizedError"}],
                "jsonapi" => {"version" => "1.0"}
              )
            end
          end
        end

        context "when Not Found" do
          response(404, "Not Found") do
            let(:id) { "6e0f4e67-798e-4eb5-a900-a19b1357aacc" }

            run_test! do |response|
              expect(JSON.parse(response.body)).to eq(
                "errors" => [{"detail" => "Intake not found", "title" => "ActiveRecord::RecordNotFound"}],
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
