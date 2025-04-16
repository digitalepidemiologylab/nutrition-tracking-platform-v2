# frozen_string_literal: true

require "rails_helper"

describe(Collab::IntakesController) do
  let!(:collaborator_admin) { create(:collaborator, :admin) }
  let!(:intake) { create(:intake) }
  let!(:user) { intake.annotation.participation.user }

  before { sign_in(collaborator_admin) }

  describe "#index" do
    it do
      get collab_user_intakes_path(user)
      expect(response).to have_http_status(:success)
    end
  end
end
