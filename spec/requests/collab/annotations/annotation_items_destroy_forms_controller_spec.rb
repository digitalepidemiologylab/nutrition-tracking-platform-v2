# frozen_string_literal: true

require "rails_helper"

describe(Collab::Annotations::AnnotationItemsDestroyFormsController) do
  let!(:collaborator) { create(:collaborator, :admin) }
  let!(:annotation) { create(:annotation) }
  let!(:annotation_item_1) { create(:annotation_item, :with_polygon_set, annotation: annotation, position: 1) }
  let!(:annotation_item_2) { create(:annotation_item, :with_polygon_set, annotation: annotation, position: 2) }

  before { sign_in(collaborator) }

  describe "#create" do
    context "with turbo_stream format" do
      let(:request) do
        delete collab_annotation_annotation_items_destroy_form_path(annotation),
          params: {
            annotations_annotation_items_destroy_form: {annotation_item_ids: [annotation_item_1.id, annotation_item_2.id]}
          },
          headers: turbo_stream_headers
      end

      context "when successful" do
        it do
          request
          expect(response).to have_http_status(:ok)
        end
      end

      context "when failed" do
        before do
          allow_any_instance_of(Annotations::AnnotationItemsDestroyForm).to receive(:save).and_return(false)
          allow_any_instance_of(Annotations::AnnotationItemsDestroyForm).to receive(:errors)
            .and_return(
              ActiveModel::Errors.new(Annotations::AnnotationItemsDestroyForm.new(annotation: annotation))
                .tap { |e|
                  e.add(:base, "Select at least 1 item to delete")
                }
            )
        end

        it do
          request
          expect(response).to have_http_status(:ok)
          expect(flash[:alert]).to eq("Unable to delete items: Select at least 1 item to delete")
        end
      end
    end
  end
end
