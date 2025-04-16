# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Collab::BaseController) do
  describe "authorization redirection" do
    before do
      allow_any_instance_of(Collab::CohortsController).to receive(:index).and_raise(Pundit::NotAuthorizedError)
    end

    context "when the collaborator is not logged" do
      it do
        get collab_cohorts_path
        expect(response).to redirect_to(new_collaborator_session_path)
        expect(flash[:alert]).to eq("You are not authorized to perform this action.")
      end
    end

    context "when the collaborator is logged in" do
      let(:collaborator) { create(:collaborator) }

      before { sign_in(collaborator) }

      context "when there is no referer in the request" do
        it do
          get collab_cohorts_path
          expect(response).to redirect_to(collab_profile_path)
          expect(flash[:alert]).to eq("You are not authorized to perform this action.")
        end
      end

      context "when there is a referer in the request" do
        let(:referer) { collab_annotations_url }

        it do
          get collab_cohorts_path, headers: {HTTP_REFERER: referer}
          expect(response).to redirect_to(referer)
          expect(flash[:alert]).to eq("You are not authorized to perform this action.")
        end
      end
    end
  end

  describe "#user_for_paper_trail" do
    let(:collaborator) { create(:collaborator) }

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
      before { sign_in(collaborator) }

      it do
        get custom_path
        expect(response.body).to eq("Collaborator #{collaborator.id}")
      end
    end

    context "when collaborator is not signed in" do
      it do
        get custom_path
        expect(response.body).to eq("Unknown")
      end
    end
  end
end
