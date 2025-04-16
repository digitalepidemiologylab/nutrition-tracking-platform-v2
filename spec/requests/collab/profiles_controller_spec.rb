# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Collab::ProfilesController) do
  let(:collaborator) { create(:collaborator) }

  before { sign_in(collaborator) }

  describe "GET /profile" do
    it do
      get collab_profile_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /profile/edit" do
    it do
      get edit_collab_profile_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "PUT /profile" do
    let(:request) { put collab_profile_path, params: {collaborator: params} }

    context "with valid params" do
      let(:params) { {name: "A new name", timezone: "Asia/Kolkata"} }

      it do
        request
        expect(response).to redirect_to(collab_profile_path)
        expect(collaborator.reload.name).to eq("A new name")
        expect(collaborator.reload.timezone).to eq("Asia/Kolkata")
      end
    end

    context "with invalid params" do
      let(:params) { {name: ""} }

      it do
        request
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
