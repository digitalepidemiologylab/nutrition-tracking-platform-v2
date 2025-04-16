# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Collab::ApiDocumentationsController) do
  let(:collaborator) { create(:collaborator) }

  before { sign_in(collaborator) }

  describe "#api_v2" do
    it do
      get api_v2_collab_api_documentation_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "#collab_api_v1" do
    it do
      get collab_api_v1_collab_api_documentation_path
      expect(response).to have_http_status(:success)
    end
  end
end
