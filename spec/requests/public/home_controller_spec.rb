# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Public::HomeController) do
  describe "#show" do
    context "when anonymous visitor" do
      it do
        get root_path
        expect(response).to have_http_status(:success)
      end
    end

    context "when signed in collaborator" do
      before do
        sign_in(collaborator)
        get(root_path, headers: {cookie: cookie})
      end

      context "when has access to annotations" do
        let(:collaborator) { create(:collaborator, :admin) }
        let(:cookie) { nil }

        describe "when no previous cookies[:annotations_query_params] is avialable" do
          let(:cookie) { nil }

          it { expect(response).to redirect_to(collab_annotations_path(filter: {status: "annotatable"})) }
        end

        describe "when cookies[:annotations_query_params] is available" do
          let(:cookie) {
            value = {direction: "desc", sort: "updated_at"}.to_json
            "annotations_query_params=#{value}"
          }

          it { expect(response).to redirect_to(collab_annotations_path(sort: "updated_at", direction: "desc")) }
        end
      end

      context "when has no access to annotations" do
        let(:collaborator) { create(:collaborator) }
        let(:cookie) { nil }

        it { expect(response).to redirect_to(collab_profile_path) }
      end
    end
  end
end
