# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Collab::Annotations::ConfirmationsController) do
  let(:collaborator) { create(:collaborator, :admin) }

  before { sign_in(collaborator) }

  describe "#create" do
    let(:request) { post collab_annotation_confirmation_path(annotation), headers: turbo_stream_headers }

    context "when success" do
      let(:annotation) { create(:annotation, :annotatable) }

      it do
        request
        expect(response).to redirect_to(collab_annotations_path(filter: {status: "annotatable"}))
        expect(flash[:notice]).to eq("Annotation confirmed successfully")
      end
    end

    context "when failed" do
      let(:annotation) { create(:annotation, :with_dish_image) }

      it do
        request
        expect(response).to have_http_status(:unprocessable_entity)
        expect(flash[:alert]).to eq("Unable to confirm annotation. ")
      end
    end
  end
end
