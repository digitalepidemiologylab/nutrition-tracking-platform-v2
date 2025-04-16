# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Collab::AnnotationsController) do
  let(:collaborator) { create(:collaborator, :admin) }
  let(:dish) { create(:dish) }
  let!(:annotation) { create(:annotation, dish: dish) }

  before { sign_in(collaborator) }

  describe "GET /index" do
    context "without pagination params" do
      it do
        get collab_annotations_path
        expect(response).to have_http_status(:success)
        expect(cookies[:annotations_query_params]).to eq({}.to_json)
      end
    end

    context "with pagination params" do
      context "when valid" do
        it do
          get collab_annotations_path, params: {annotations_page: 1}
          expect(response).to have_http_status(:ok)
          expect(cookies[:annotations_query_params]).to eq({}.to_json)
        end
      end

      context "when invalid" do
        let(:params) { {annotations_page: 3} }

        it do
          get(collab_annotations_path, params: params)
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context "with filter params" do
      context "when valid" do
        it do
          get collab_annotations_path, params: {filter: {status: :annotatable}}
          expect(response).to have_http_status(:ok)
          expect(cookies[:annotations_query_params]).to eq({filter: {status: "annotatable"}}.to_json)
        end
      end

      context "when invalid" do
        it do
          expect { get collab_annotations_path, params: {filter: {status: :invalid}} }
            .to raise_error(BaseQuery::BadFilterParam, "Status not supported")
          expect(cookies[:annotations_query_params]).to be_nil
        end
      end
    end
  end

  describe "GET /show" do
    it do
      get collab_annotation_path(annotation)
      expect(response).to have_http_status(:success)
    end
  end
end
