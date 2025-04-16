# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Collab::AnnotationProductsController) do
  let(:collaborator) { create(:collaborator, :admin) }
  let!(:annotation) { create(:annotation) }

  before do
    create_base_units
    sign_in(collaborator)
  end

  describe "#create" do
    context "with turbo_stream format" do
      let(:request) do
        post collab_annotation_annotation_products_path(annotation), headers: turbo_stream_headers
      end

      it do
        expect { request }
          .to change { annotation.annotation_items.count }.by(1)
        expect(response).to have_http_status(:success)
        expect(response.body).to match("<turbo-stream action=\"prepend\"")
        expect(response.body).not_to match("Item must exist")
      end
    end
  end
end
