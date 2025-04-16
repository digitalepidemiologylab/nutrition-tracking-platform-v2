# frozen_string_literal: true

require "rails_helper"

describe(Collab::Api::V1::BaseController) do
  let(:collaborator) { create(:collaborator) }

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

    context "when collaborator is signed in" do
      it do
        get custom_path, headers: collab_auth_headers(collaborator)
        expect(response.body).to eq("Collaborator #{collaborator.id}")
      end
    end
  end
end
