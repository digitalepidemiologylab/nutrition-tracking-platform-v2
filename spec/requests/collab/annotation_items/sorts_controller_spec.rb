# frozen_string_literal: true

require "rails_helper"

describe(Collab::AnnotationItems::SortsController) do
  let(:collaborator) { create(:collaborator, :admin) }
  let!(:annotation) { create(:annotation, :with_annotation_items) }
  let!(:annotation_item_1) { annotation.annotation_items.first }
  let!(:annotation_item_2) { annotation.annotation_items.second }

  before do
    sign_in(collaborator)
  end

  describe "#update" do
    context "with turbo_stream format" do
      let(:request) {
        put collab_annotation_item_sort_path(annotation_item_1), params: {position: 1},
          headers: turbo_stream_headers
      }

      context "when successful" do
        it do
          expect { request }
            .to change { annotation_item_1.reload.position }.from(1).to(2)
          expect(response.body).to match("<turbo-stream action=\"update\"")
        end
      end

      context "when sorting fails" do
        let(:sort_service) { instance_double(AnnotationItems::SortService) }

        before do
          allow(AnnotationItems::SortService).to receive(:new).and_return(sort_service)
          allow(sort_service).to receive(:call).and_return(false)
        end

        it do
          expect { request }
            .not_to change { annotation_item_1.reload.position }.from(1)
          expect(response.body).to match("<turbo-stream action=\"update\"")
          expect(response.body).to match("Failed to reorder items")
        end
      end
    end
  end
end
