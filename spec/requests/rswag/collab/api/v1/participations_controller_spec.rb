# frozen_string_literal: true

require "rails_helper"
require "swagger_helper"

# rubocop:disable RSpec/EmptyExampleGroup
describe("/collab/api/v1/cohorts/{id}/participations", :freeze_swagger_time, swagger_doc: "collab/v1/swagger.json") do
  let(:cohort_id) { "29f8eb15-206e-4f17-9835-014619d33f5f" }
  let(:cohort) { create(:cohort, id: cohort_id) }
  let(:collaborator) { create(:collaborator, id: "e672ebba-34c1-45d1-b11e-3cb43b30cbfb") }
  let!(:collaboration) { create(:collaboration, :manager, id: "aabfeaab-aeae-4ea2-922e-303bebad1639", collaborator: collaborator, cohort: cohort) }
  let(:headers) { collab_auth_headers(collaborator) }

  describe "index" do
    let!(:participation_1) { create(:participation, cohort: cohort) }
    let!(:participation_2) { create(:participation, cohort: cohort) }

    path "/collab/api/v1/cohorts/{cohort_id}/participations" do
      get("list cohort participations") do
        tags "Participations"
        set_http_headers
        parameter name: :cohort_id, in: :path, type: :string, description: "Cohort ID"
        parameter name: :page, in: :query, type: :integer,
          description: "Page number"
        parameter name: :items, in: :query, type: :integer,
          description: "Number of items per page (default is #{Pagy::DEFAULT[:items]}, max is #{Pagy::DEFAULT[:max_items]})"
        parameter name: :include, in: :query, type: :string,
          description: include_param_description(Collab::Api::V1::ParticipationPolicy)
        let(:page) { "1" }
        let(:items) { "5" }
        let(:include) { "cohort" }

        context "when successful" do
          response(200, "OK") do
            run_test! do |response|
              body = JSON.parse(response.body)
              expect(body["data"].size).to eq(2)
              expect(body["data"].first.keys).to contain_exactly("id", "type", "attributes", "relationships")
            end
          end
        end
      end
    end
  end

  describe "show" do
    let!(:participation) { create(:participation, cohort: cohort) }

    path "/collab/api/v1/participations/{participation_id}" do
      get("show participation") do
        tags "Participations"
        set_http_headers
        parameter name: :participation_id, in: :path, type: :string, description: "Participation ID"
        parameter name: :include, in: :query, type: :string,
          description: include_param_description(Collab::Api::V1::ParticipationPolicy)
        let(:participation_id) { participation.id }
        let(:include) { "cohort" }

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
            let(:participation_id) { participation.id }
            let(:other_collaborator) { create(:collaborator, id: "3ad45fc5-7d96-4489-bd1d-b71ead70a293") }
            let(:headers) { collab_auth_headers(other_collaborator) }

            run_test! do |response|
              expect(JSON.parse(response.body)).to eq(
                "errors" => [
                  {"detail" => "not allowed to show? this Participation", "title" => "Pundit::NotAuthorizedError"}
                ],
                "jsonapi" => {"version" => "1.0"}
              )
            end
          end
        end

        context "when Not Found" do
          response(404, "Not Found") do
            let!(:participation_id) { "b57c77cf-ffba-4bf4-b994-ef53ab41164e" }

            run_test! do |response|
              expect(JSON.parse(response.body)).to eq(
                "errors" => [{"detail" => "Participation not found", "title" => "ActiveRecord::RecordNotFound"}],
                "jsonapi" => {"version" => "1.0"}
              )
            end
          end
        end
      end
    end
  end

  describe "create" do
    path "/collab/api/v1/cohorts/{cohort_id}/participations" do
      post("create cohort participation") do
        tags "Participations"
        set_http_headers
        parameter name: :cohort_id, in: :path, type: :string, description: "Cohort ID"
        parameter name: :include, in: :query, type: :string,
          description: include_param_description(Collab::Api::V1::ParticipationPolicy)
        let(:include) { "cohort" }

        context "when successful" do
          response(200, "OK") do
            run_test! do |response|
              body = JSON.parse(response.body)
              expect(body["data"].keys).to contain_exactly("id", "type", "attributes", "relationships")
            end
          end
        end

        context "when failed" do
          before do
            allow_any_instance_of(Participation).to receive(:save).and_return(false)
            allow_any_instance_of(Participation).to receive(:errors)
              .and_return(ActiveModel::Errors.new(Participation.new).tap { |e|
                e.add(:base, "Unable to save partipation")
              })
          end

          response(422, "Unprocessable Entity") do
            run_test! do |response|
              expect(JSON.parse(response.body))
                .to eq(
                  "errors" => [{"detail" => "Unable to save partipation", "source" => {}, "title" => "Invalid base"}],
                  "jsonapi" => {"version" => "1.0"}
                )
            end
          end
        end
      end
    end
  end

  describe "update" do
    let!(:participation) { create(:participation, cohort: cohort) }
    let(:participation_id) { participation.id }

    path "/collab/api/v1/participations/{participation_id}" do
      patch("update participation") do
        tags "Participations"
        set_http_headers
        parameter name: :participation_id, in: :path, type: :string, description: "Participation ID"
        parameter name: :data, in: :body, schema: {
          type: :object,
          properties: {
            type: {type: :string, enum: ["participations"]},
            attributes: {
              type: :object,
              properties: {
                ended_at: {type: :string, format: :date_time}
              }
            }
          }
        }
        parameter name: :include, in: :query, type: :string,
          description: include_param_description(Collab::Api::V1::ParticipationPolicy)
        let(:data) do
          {
            data: {
              type: "participations",
              attributes: {
                ended_at: participation.ended_at + 1.day
              }
            }
          }
        end
        let(:include) { "cohort" }

        context "when successful" do
          response(200, "OK") do
            run_test! do |response|
              body = JSON.parse(response.body)
              expect(body["data"].keys).to contain_exactly("id", "type", "attributes", "relationships")
              expect(body["data"]["attributes"]["ended_at"]).to eq("2021-12-20T12:12:12.000000Z")
            end
          end
        end

        context "when failed" do
          before do
            allow_any_instance_of(Participation).to receive(:save).and_return(false)
            allow_any_instance_of(Participation).to receive(:errors)
              .and_return(ActiveModel::Errors.new(Participation.new).tap { |e|
                e.add(:base, "Unable to save partipation")
              })
          end

          response(422, "Unprocessable Entity") do
            run_test! do |response|
              expect(JSON.parse(response.body))
                .to eq(
                  "errors" => [{"detail" => "Unable to save partipation", "source" => {}, "title" => "Invalid base"}],
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
