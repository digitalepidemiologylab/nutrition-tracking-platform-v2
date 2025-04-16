# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Api::V2::ParticipationsController) do
  let(:user) { create(:user) }
  let(:body) { JSON.parse(response.body) }

  before { api_sign_in(user) }

  describe "#index" do
    let!(:participation) { create(:participation, user: user) }
    let!(:participation_not_associated) { create(:participation, :not_associated) }
    let!(:other_participation) { create(:participation) }

    it do
      get api_v2_participations_path, headers: auth_params
      expect(body["data"].count).to eq(1)
      expect(body["included"]).to be_nil
      expect(body["meta"]).to eq({"page" => 1, "prev" => nil, "next" => nil, "last" => 1})
    end

    context "with include params" do
      it do
        get api_v2_participations_path, headers: auth_params, params: {include: "cohort"}
        expect(body["data"].count).to eq(1)
        expect(body["included"].count { |i| i["type"] == "cohorts" }).to eq(1)
      end
    end
  end
end
