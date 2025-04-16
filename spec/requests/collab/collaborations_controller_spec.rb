# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Collab::CollaborationsController) do
  let(:admin) { create(:collaborator, :admin) }
  let(:collaboration) { create(:collaboration, role: :manager) }

  before { sign_in(admin) }

  describe "#edit" do
    it do
      get edit_collab_collaboration_path(collaboration)
      expect(response).to have_http_status(:success)
    end
  end

  describe "#update" do
    let(:request) { put collab_collaboration_path(collaboration), params: {collaboration: params} }

    context "with valid params" do
      let(:params) { {role: "annotator"} }

      it do
        expect { request }
          .to change { collaboration.reload.role }.from("manager").to("annotator")
        expect(response).to redirect_to(collab_cohort_path(collaboration.cohort))
      end
    end

    context "with invalid params" do
      let(:params) { {role: nil} }

      it do
        request
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
