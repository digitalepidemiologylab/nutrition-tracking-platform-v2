# frozen_string_literal: true

require "rails_helper"
require "swagger_helper"

# rubocop:disable RSpec/EmptyExampleGroup
describe("/collab/api/v1/participations/{id}/annotations", :freeze_swagger_time, swagger_doc: "collab/v1/swagger.json") do
  let(:cohort_id) { "af1fd524-fb95-40bd-98e5-db091a94bfc5" }
  let(:cohort) { create(:cohort, id: cohort_id) }
  let(:collaborator) { create(:collaborator, id: "c8ae6221-6ea2-4a6d-8e32-c097cf9e286c") }
  let!(:collaboration) do
    create(
      :collaboration, :manager, id: "a38962c8-d35c-4f59-95f7-251337b3ea09", collaborator: collaborator, cohort: cohort
    )
  end
  let(:headers) { collab_auth_headers(collaborator) }
  let!(:participation) { create(:participation, cohort: cohort) }
  let(:participation_id) { participation.id }

  describe "index" do
    before { create_list(:annotation, 6, participation: participation) }

    path "/collab/api/v1/participations/{participation_id}/annotations" do
      get("list participation annotations") do
        tags "Annotations"
        set_http_headers
        parameter name: :participation_id, in: :path, type: :string, description: "Participation ID"
        parameter name: :page, in: :query, type: :integer, description: "Page number"
        parameter name: :items, in: :query, type: :integer,
          description: "Number of items per page (default is " \
            "#{Collab::Api::V1::AnnotationsController::DEFAULT_ITEMS}, " \
            "max is #{Collab::Api::V1::AnnotationsController::MAX_ITEMS})"
        parameter name: :include, in: :query, type: :string,
          description: include_param_description(Collab::Api::V1::AnnotationPolicy)
        let(:page) { "1" }
        let(:items) { "5" }
        let(:include) { "dish,dish.dish_image,intakes,comments" }

        context "when successful" do
          response(200, "OK") do
            run_test! do |response|
              body = JSON.parse(response.body)
              expect(body["data"].size).to eq(5)
              expect(body["data"].first.keys).to contain_exactly("id", "type", "attributes", "relationships")
            end
          end
        end
      end
    end
  end
end
# rubocop:enable RSpec/EmptyExampleGroup
