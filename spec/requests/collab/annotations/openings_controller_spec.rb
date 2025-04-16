# frozen_string_literal: true

require "rails_helper"

describe(Collab::Annotations::OpeningsController) do
  let(:collaborator) { create(:collaborator, :admin) }

  before { sign_in(collaborator) }

  describe "#create" do
    let(:request) { post collab_annotation_opening_path(annotation) }

    context "when success" do
      let!(:annotation) { create(:annotation, :annotated) }

      it do
        request
        expect(response).to redirect_to(collab_annotation_path(annotation))
        expect(flash[:notice]).to eq("Annotation re-opened successfully")
      end
    end

    # failure is difficult to test because since an invalid status will be catch by the policy
    # and :open_annotation! is called during object setup already
  end
end
