# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Collab::Collaborators::PasswordsController) do
  # Test only #new to be sure the route is working
  describe "#new" do
    it do
      get(new_collaborator_password_path(locale: :fr))
      expect(response).to have_http_status(:success)
    end
  end
end
