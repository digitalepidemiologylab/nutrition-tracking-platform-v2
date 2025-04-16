# frozen_string_literal: true

require "rails_helper"
require "swagger_helper"

# rubocop:disable RSpec/EmptyExampleGroup
describe("/collab/api/v1/cohorts", :freeze_swagger_time, swagger_doc: "collab/v1/swagger.json") do
  let(:cohort) { create(:cohort, :with_food_list, id: "29f8eb15-206e-4f17-9835-014619d33f5f") }
  let!(:participation) { create(:participation, id: "2d6dd481-0065-4f0d-9e47-a80cb4d792c5", cohort: cohort) }
  let(:collaborator) { create(:collaborator, id: "e672ebba-34c1-45d1-b11e-3cb43b30cbfb") }
  let!(:collaboration) { create(:collaboration, :manager, id: "aabfeaab-aeae-4ea2-922e-303bebad1639", collaborator: collaborator, cohort: cohort) }
  let(:headers) { collab_auth_headers(collaborator) }

  describe "show" do
    path "/collab/api/v1/cohorts/{cohort_id}" do
      get("show cohort") do
        tags "Cohorts"
        set_http_headers
        parameter name: :cohort_id, in: :path, type: :string, description: "Cohort ID"
        parameter name: :include, in: :query, type: :string,
          description: include_param_description(Collab::Api::V1::CohortPolicy)
        let(:cohort_id) { cohort.id }
        let(:include) { "food_lists" }

        context "when OK" do
          response(200, "OK") do
            run_test! do |response|
              body = JSON.parse(response.body)
              expect(body.keys).to contain_exactly("data", "included", "jsonapi")
              expect(body["data"].keys).to contain_exactly("id", "type", "attributes", "relationships")
            end
          end
        end

        context "when Forbidden" do
          response(403, "Forbidden") do
            let(:cohort_id) { cohort.id }
            let(:other_collaborator) { create(:collaborator, id: "3ad45fc5-7d96-4489-bd1d-b71ead70a293") }
            let(:headers) { collab_auth_headers(other_collaborator) }

            run_test! do |response|
              expect(JSON.parse(response.body)).to eq(
                "errors" => [{"detail" => "not allowed to show? this Cohort", "title" => "Pundit::NotAuthorizedError"}],
                "jsonapi" => {"version" => "1.0"}
              )
            end
          end
        end

        context "when Not Found" do
          response(404, "Not Found") do
            let!(:cohort_id) { "32c5eb2f-e84c-4611-a709-5cdd1f1b7782" }

            run_test! do |response|
              expect(JSON.parse(response.body)).to eq(
                "errors" => [{"detail" => "Cohort not found", "title" => "ActiveRecord::RecordNotFound"}],
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
