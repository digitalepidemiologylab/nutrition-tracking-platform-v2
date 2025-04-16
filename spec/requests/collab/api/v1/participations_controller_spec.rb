# frozen_string_literal: true

require "rails_helper"

describe(Collab::Api::V1::ParticipationsController) do
  let(:collaborator_admin) { create(:collaborator, :admin) }
  let(:cohort) { create(:cohort) }
  let(:body) { JSON.parse(response.body) }
  let(:headers) { collab_auth_headers(collaborator_admin) }

  describe "#index" do
    let!(:participation_1) { create(:participation, cohort: cohort) }
    let!(:participation_2) { create(:participation, cohort: cohort) }
    let(:request) do
      get(collab_api_v1_cohort_participations_path(cohort), headers: headers)
    end

    it do
      request
      expect(body.keys).to contain_exactly("data", "jsonapi", "meta")
      expect(body["data"].size).to eq(2)
      expect(body["data"].pluck("id")).to contain_exactly(participation_1.id, participation_2.id)
      expect(body["data"].first.keys).to contain_exactly("id", "type", "attributes", "relationships")
      expect(body["data"].first["attributes"].keys).to contain_exactly("started_at", "ended_at", "key")
    end
  end

  describe "#show" do
    let(:participation) { create(:participation, cohort: cohort) }

    it do
      get(collab_api_v1_participation_path(participation), headers: headers)
      expect(body.keys).to contain_exactly("data", "jsonapi")
    end

    context "with include params" do
      it do
        get(collab_api_v1_participation_path(participation), headers: headers, params: {include: "cohort"})
        expect(body.keys).to contain_exactly("data", "included", "jsonapi")
        expect(body["included"].count { |i| i["type"] == "cohorts" }).to eq(1)
      end
    end
  end

  describe "#create" do
    let(:request) do
      post(collab_api_v1_cohort_participations_path(cohort), headers: headers)
    end

    context "when successful" do
      it do
        expect { request }.to change(Participation, :count).by(1)
        expect(body.keys).to contain_exactly("data", "jsonapi")
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

      it do
        expect { request }.not_to change(Participation, :count)
        expect(body).to eq(
          "errors" => [
            {
              "detail" => "Unable to save partipation", "source" => {}, "title" => "Invalid base"
            }
          ],
          "jsonapi" => {"version" => "1.0"}
        )
      end
    end
  end

  describe "#update", :freeze_time do
    let!(:participation) { create(:participation, cohort: cohort) }
    let(:new_ended_at) { participation.ended_at + 1.day }

    let(:params) do
      {
        data: {
          type: "participations",
          attributes: {
            ended_at: new_ended_at
          }
        }
      }
    end

    let(:request) do
      patch(collab_api_v1_participation_path(participation), params: params.to_json, headers: headers)
    end

    context "when successful" do
      it do
        expect { request }.to change { participation.reload.ended_at }.from(1.week.from_now).to(new_ended_at)
        expect(body.keys).to contain_exactly("data", "jsonapi")
      end
    end

    context "when failed" do
      before do
        allow_any_instance_of(Participation).to receive(:update).and_return(false)
        allow_any_instance_of(Participation).to receive(:errors)
          .and_return(ActiveModel::Errors.new(Participation.new).tap { |e|
            e.add(:base, "Unable to save partipation")
          })
      end

      it do
        expect { request }.not_to change(Participation, :count)
        expect(body).to eq(
          "errors" => [
            {
              "detail" => "Unable to save partipation", "source" => {}, "title" => "Invalid base"
            }
          ],
          "jsonapi" => {"version" => "1.0"}
        )
      end
    end
  end
end
