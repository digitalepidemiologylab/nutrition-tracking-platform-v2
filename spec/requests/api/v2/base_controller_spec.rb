# frozen_string_literal: true

require "rails_helper"

describe(Api::V2::BaseController) do
  let(:user) { create(:user) }

  describe "#user_for_paper_trail" do
    before do
      klass = Class.new(described_class) do
        skip_after_action :verify_authorized

        def custom
          render plain: user_for_paper_trail
        end
      end
      stub_const("TestsController", klass)

      Rails.application.routes.disable_clear_and_finalize = true

      Rails.application.routes.draw do
        get "/custom", to: "tests#custom"
      end
    end

    after { Rails.application.reload_routes! }

    context "when user is signed in" do
      before { api_sign_in(user) }

      it do
        get custom_path, headers: auth_params
        expect(response.body).to eq("User #{user.id}")
      end
    end
  end
end
