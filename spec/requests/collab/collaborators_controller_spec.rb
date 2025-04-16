# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Collab::CollaboratorsController) do
  let(:collaborator) { create(:collaborator, :admin) }

  before { sign_in(collaborator) }

  describe "#index" do
    it do
      get collab_collaborators_path
      expect(response).to have_http_status(:success)
    end
  end
end
