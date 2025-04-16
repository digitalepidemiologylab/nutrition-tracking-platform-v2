# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Api::V2::ParticipateController) do
  let(:user) { create(:user, password: "password") }
  let!(:participation) { create(:participation, :not_associated) }
  let(:body) { JSON.parse(response.body) }

  before { api_sign_in(user) }

  describe "#create" do
    let(:request) { post api_v2_participate_path, params: params.to_json, headers: auth_params }
    let(:params) do
      {
        data: {
          type: :participations,
          attributes: {
            key: participation.key
          }
        },
        include: "cohort"
      }
    end

    context "when successful" do
      it do
        expect { request }
          .to change { participation.reload.user_id }.to(user.id)
          .and(change { participation.reload.user_id }.to(user.id))
        expect(response).to have_http_status(:success)
        expect(body["data"].keys).to contain_exactly("attributes", "id", "relationships", "type")
        expect(body["included"].size).to eq(1)
      end
    end

    context "when failed" do
      before do
        service = Participations::ResetService.new(participation: participation)
        allow_any_instance_of(Participations::ParticipateService)
          .to receive(:call).and_raise(ActiveModel::ValidationError.new(service), I18n.t("errors.messages.exclusion"))
        allow_any_instance_of(Participations::ParticipateService)
          .to receive(:errors)
          .and_return(ActiveModel::Errors.new(service)
          .tap { |e| e.add(:key, "not available") })
      end

      it do
        expect { request }
          .to not_change { participation.reload.user_id }
          .and(not_change { participation.reload.user_id })
        expect(body)
          .to eq(
            "errors" => [
              {"detail" => "Key not available", "source" => {}, "title" => "Invalid key"}
            ],
            "jsonapi" => {"version" => "1.0"}
          )
      end
    end
  end
end
